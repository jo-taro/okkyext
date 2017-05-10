module Options.Layout 
  ( view
  , update
  , everySecEffect
  ) where

import Common
import Control.Comonad (extract)
import Control.Monad.Aff (makeAff, attempt, forkAff, later, later')
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Except (runExcept)
import Control.Monad.Eff.Exception (Error, message)
import Control.Monad.Eff.Now (nowDateTime)
import Data.Array (filter, snoc)
import Data.Either (Either(..), either)
import Data.Formatter.DateTime (parseFormatString, format)
import Data.Lens (view, set, over) as L
import Data.Maybe (Maybe(..))
import Options.Common (NickCheckStatus(..))
import Network.HTTP.Affjax (affjax, defaultRequest)
import Network.HTTP.RequestHeader (RequestHeader(..))
import Parser (trimUserLink, trimUserNick)
import Prelude (($), bind, pure, const, (/=), (>>>), flip, (<#>), (<>), show, Unit)
import Pux (EffModel, noEffects, onlyEffects)
import Pux.Html (Html, div)
import Signal (Signal, (~>))
import Signal.Time (Time, second, every)

import Options.InputForm (renderInsertForm)
import Options.ListTable (renderUserList)
import Options.ToolBar (renderToolBar)


import Control.Monad.Except.Trans (except, runExceptT)

import Data.Foldable (notElem)

import Control.Monad.Aff.AVar (putVar, takeVar, makeVar)
import Control.Monad.Eff.Exception (Error, error)
import Control.Monad.Eff.Console (log)

import WebWorker (WebWorker, onmessageFromWorker, MessageEvent(MessageEvent), OwnsWW, postMessageToWorker, mkWorker, terminateWorker)
import Data.Foreign (toForeign)
import Data.Foreign.Class (read, readEitherR)
import Options.Common (State, Action(..), NickCheckStatus(..), Message(..))

everySec :: Signal Time
everySec = every second

everySecEffect :: Signal Action
everySecEffect = everySec ~> const UpdateCurrentTime

-- html rendering
view :: State -> Html Action
view state = do
  div
    []
    [ renderToolBar state
    , renderInsertForm state
    , renderUserList state
    ]

-- managing state of ui

update :: Action -> State -> EffModel State Action AppEffects

-- link related states
update (LinkChange event) state =
  case trimUserLink event.target.value of
    Nothing ->
      { state : L.set
                  atStateLink
                  (event.target.value <> "=> 올바른 사용자 주소가 아닙니다")
                  state
      , effects : [ pure $ LinkIncorrectFormat ]
      }
    Just url ->
      { state : L.set atStateLink url >>>
                L.set atStateName "okky에서 정보를 가져오는 중입니다" >>>
                L.set atIsloading Checking $ state
      , effects : [ pure $ LinkAjaxFetch ]
      }

update LinkAjaxFetch state =
  { state : L.set atLinkInputDisabled true $  state
  , effects:
      [ do
          let headers = [ RequestHeader "GET" "Access-Control-Request-Method"
                        , RequestHeader "GET" "Access-Control-Request-Headers"
                        ]
              nickUrl = "https://okky.kr" <> L.view atStateLink state
              request = defaultRequest { url = nickUrl, headers = headers }
          
          httpResponse <- attempt $ affjax request
          pure $ case httpResponse of
            Left  err  -> AutoNameChange (message err) NetworkFail
            -- Left  err  -> LinkParse "foooooo"
            Right resp -> LinkParse resp.response
      ]
  }

update (LinkParse htmlText) state = onlyEffects state $
  [ do
      -- bar:: forall a.
      -- WebWorker
      -- -> (Error -> Eff  ( ownsww :: OwnsWW | a ) Unit )
      -- -> (String -> Eff ( ownsww :: OwnsWW | a ) Unit )
      -- -> Eff ( ownsww :: OwnsWW | a ) Unit
      let handler err succ (MessageEvent {data: fn}) =
            either 
              (\e -> err $ error $ show e) 
              (\(Message {message}) -> succ message) 
              (runExcept $ read fn) 

      parseWorker <- liftEff $  mkWorker state.parseWorkerFilename
      liftEff $ postMessageToWorker parseWorker $ toForeign (Message {message: htmlText})
      mess <- attempt $ makeAff (\err succ -> 
                                    onmessageFromWorker parseWorker (handler err succ)
                                )
      liftEff $ terminateWorker parseWorker
      pure $ case mess of
        Left err  -> AutoNameChange (message err) ParseFail
        -- Left err  -> AutoNameChange "fooo" Success
        Right res -> AutoNameChange res Success
  ]

update (LinkDragEnter event) state = noEffects $
  L.set atStateLink "" >>>
  L.set atLinkInputDisabled false $  state

update (LinkDragLeave event) state = noEffects $
  L.set atLinkInputDisabled true  state

update (LinkIncorrectFormat) state = noEffects $
  L.set atLinkInputDisabled true  state


-- name related states
update (NameChange event) state = noEffects $ state
  -- L.set atStateName (trimUserLink event.target.value) state

update (AutoNameChange resultString nickCheckStatus) state = noEffects $
  L.set atIsloading nickCheckStatus >>>
  L.set atStateName resultString $ state


-- note related states
update (NoteChange event) state = noEffects $
  L.set atStateNote event.target.value state


-- date related states
update UpdateCurrentTime state = onlyEffects state $
  [ do
      localTime <- liftEff $ nowDateTime
      pure $ DateChange $ extract localTime
  ]

update (DateChange dateTime) state = noEffects $
  case parseFormatString "YYYY-MM-DD hh:mm:ss" <#> flip format dateTime  of
    Left _ -> L.set atStateDate "error" state
    Right x -> L.set atStateDate x state

-- color related states
update (BlockTextChange event) state = noEffects $
  L.set atStateBlockText (show event.target.checked) state

update (TextColorChange event) state = noEffects $
  L.set atStateTextColor event.target.value state

update (BackColorChange event) state = noEffects $
  L.set atStateBackColor event.target.value state

-- crude operation states
update AddEntry state =
  { state : L.set atEntry defaultEntry >>>
            L.set atIsloading Idle >>>
            L.over atBlackUsers (\x -> snoc x state.entry)  $ state
  , effects :
      [ pure $ WriteItem ]
  }

update WriteItem state = onlyEffects state $
  [ do
      liftEff $ writeLocalStorage (L.view atList state)
      pure $ WriteComplete
  ]

update FlushDeleteQueue state =
  let input = (L.view atBlackUsers state)
      queue = (L.view atDeleteQueueBlackUsers state)
      output  = filter (flip notElem queue) input
      newList = Blacklist { blackUsers : output }
  in { state :  L.set atList newList >>>
                L.set atDeleteQueue defaultList $ state
     , effects :
        [ do
            liftEff $ writeLocalStorage newList 
            pure $ WriteComplete
        ]
     }
update AbortDeleteQueue state = noEffects $
  L.set atDeleteQueue defaultList state 
    
update (ReadComplete list) state = noEffects $
  -- L.set atDelBtnDisabled true >>>
  L.set atList list $ state

update (WriteComplete) state = noEffects $ state
  -- L.set atDelBtnDisabled true state

update (AddDeleteQueue entry) state = noEffects $
  -- L.set atDelBtnDisabled false >>>
  L.over atDeleteQueueBlackUsers (flip snoc entry) $ state

update (RemoveDeleteQueue entry) state = noEffects $
  -- L.set atDelBtnDisabled false >>>
  L.over atDeleteQueueBlackUsers (filter ((/=)entry)) $ state




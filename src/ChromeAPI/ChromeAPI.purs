module ChromeAPI
  ( Command(..)
  , Chrome
  , ResponseData(..)
  , Request
  , Sender
  , addListener
  , sendMessage
  , unwrapCommand
  ) where

import Prelude (Unit)
import Data.Foreign (Foreign)
import Control.Monad.Eff (Eff)
import DOM (DOM)
import DOM.WebStorage (STORAGE)
import Control.Monad.Eff.Console (CONSOLE)

foreign import data Chrome :: !

data Command = Command
  { method :: String
  , key :: String
  }

unwrapCommand (Command cmd) = cmd

data ResponseData = ResponseData { data :: Array String }

type Request = Foreign
type Sender = Foreign

foreign import sendMessage
    :: forall e
     . Command
    -> (ResponseData -> Eff (chrome :: Chrome | e) Unit)
    -> Eff (chrome :: Chrome | e) Unit

foreign import addListener
    :: forall e1 e2 e3.
    ( Command -> Sender
              -> ( ResponseData -> Eff ( chrome :: Chrome
                                        , dom :: DOM
                                        , storage :: STORAGE
                                        , console :: CONSOLE | e1) Unit
                 )
              -> Eff ( chrome :: Chrome
                     , dom :: DOM
                     , storage :: STORAGE
                     , console :: CONSOLE | e2) Unit
    )
    -> Eff ( chrome :: Chrome
           , dom :: DOM
           , storage :: STORAGE
           , console :: CONSOLE | e3) Unit

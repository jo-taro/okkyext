module Options where


import Control.Bind ((=<<))
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Options.Layout (view, update, everySecEffect)
import Prelude (bind, pure)
import Pux (App, Config, CoreEffects, renderToDOM, start)
import Pux.Devtool (Action, start) as Pux.Devtool
import WebWorker (mkWorker)

import Control.Monad.Eff.Console (CONSOLE)
import Common (AppEffects, atList, readLocalStorage,defaultList, defaultEntry)
import DOM.WebStorage (STORAGE)
import Data.Lens (set) as L

import Options.Common


--  Options page initial state
init :: State
init =
  { list : defaultList
  , deleteQueue : defaultList
  , entry : defaultEntry
  , delBtnDisabled : false
  , isloading : Idle
  , linkInputDisabled : true
  , textColor : "#d3d3d3"
  , backColor : "#ffffff"
  , parseWorkerFilename : "parseworker.min.js"
  }

initDebug :: State
initDebug =
  { list : defaultList
  , deleteQueue : defaultList
  , entry : defaultEntry
  , delBtnDisabled : false
  , isloading : Idle
  , linkInputDisabled : true
  , textColor : "#d3d3d3"
  , backColor : "#ffffff"
  , parseWorkerFilename : "parseworker.js"
  }


-- Load list from localstorage
config :: forall eff. State
               -> Eff ( console :: CONSOLE
                      , dom     :: DOM
                      , storage :: STORAGE | eff) (Config State Action AppEffects)
config state = do
  list <- readLocalStorage
  let loadedState = L.set atList list state
  pure
    { initialState: loadedState
    , update: update
    , view: view
    , inputs: [everySecEffect]
    }


main :: State -> Eff (CoreEffects AppEffects) (App State Action)
main state = do
  app <- start =<< config state
  renderToDOM "#app" app.html
  pure app

-- Entry point for the browser with pux-devtool injected.
debug :: State -> Eff (CoreEffects AppEffects) (App State (Pux.Devtool.Action Action))
debug state = do
  app <- Pux.Devtool.start =<< config state
  renderToDOM "#app" app.html
  pure app

module ChromeAPI
  ( Chrome
  , addListener
  , sendMessage
  ) where

import Prelude (Unit)
import Control.Monad.Eff (Eff)
import DOM (DOM)
import DOM.WebStorage (STORAGE)
import Control.Monad.Eff.Console (CONSOLE)

foreign import data Chrome :: !

foreign import sendMessage
    :: forall c r e
     . c
    -> (r -> Eff (chrome :: Chrome | e) Unit)
    -> Eff (chrome :: Chrome | e) Unit

foreign import addListener
    :: forall c s r  e1 e2 e3.
    ( c -> s
              -> ( r -> Eff ( chrome :: Chrome
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

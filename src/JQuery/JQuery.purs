module JQuery where

import Prelude (Unit)
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Control.Monad.Eff.JQuery (JQuery, Selector)

-- there's no ffi for parents api on the purescript-jquery
-- which selects parents on given element with selector.
foreign import parents
  :: forall eff
   . Selector
  -> JQuery
  -> Eff (dom :: DOM | eff) JQuery

-- | Set CSS properties.
foreign import cssp
  :: forall eff css
   . { | css }
  -> JQuery
  -> Eff (dom :: DOM | eff) Unit

module Back where

import Common (ChromeEffects, readLocalStorage, atBlackUserEntries, atLink)
import Data.Functor ((<$>))
import Data.Lens (view) as L
import Data.Lens.Fold (toListOf) as F
import ChromeAPI (addListener)
import ChromeMessages (Command, Sender, ResponseData(..), unwrapCommand)
import Prelude (bind, Unit, ($), (>>=), (==))
import Data.Array (fromFoldable)


-- Backgorund page for the extension. this page persists all the time
-- This page responses of the list request from content page.

handleResponse :: forall eff.
    Command
    -> Sender
    -> ( ResponseData -> ChromeEffects eff Unit )
    -> ChromeEffects eff Unit

handleResponse command sender sendResponse = do
  result <- readLocalStorage
  let cmd = unwrapCommand command
      blackUsers = F.toListOf atBlackUserEntries result

  if cmd.method == "getLocalStorage"
    then sendResponse $ ResponseData { data : fromFoldable blackUsers }
    else sendResponse $ ResponseData { data : [] }


main :: forall eff. ChromeEffects eff Unit
main = do
  addListener handleResponse

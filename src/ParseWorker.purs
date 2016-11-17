module ParseWorker where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (error,message) as E 
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Foreign (toForeign)
import Data.Foreign.Class (read)
import Data.Foreign.Class (read)
import Options.Common (Message(Message))
import Parser (trimUserNick)
import Prelude (Unit, ($), id)
import Pux.Html.Attributes (offset)
import WebWorker (MessageEvent(MessageEvent), IsWW, postMessage, onmessage)

main :: forall eff. Eff ( isww :: IsWW | eff ) Unit
main = onmessage handler
  where
    errorM = Message { message: "Failed to read Message in WW" }
    succ m = Message { message: either E.message id $ trimUserNick m }
    handler (MessageEvent {data: fn}) =
      either (\_ -> postMessage $ toForeign errorM) 
      (\(Message {message}) -> postMessage $ toForeign (succ message)) 
      (runExcept $ read fn)

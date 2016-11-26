module ChromeMessages
  ( Command(..)
  , ResponseData(..)
  , Request
  , Sender
  , unwrapCommand ) where

import Common (BlacklistEntry)
import Data.Foreign (Foreign)

data Command = Command
  { method :: String
  , key :: String
  }

unwrapCommand (Command cmd) = cmd

data ResponseData = ResponseData { data :: Array BlacklistEntry }

type Request = Foreign
type Sender = Foreign

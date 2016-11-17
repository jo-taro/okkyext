module Options.Common
  ( Action(..)
  , NickCheckStatus(..)
  , State(..)
  , Message(..)
  ) where

import Common
import Pux.Html.Events as PE
import Data.DateTime (DateTime)
import Data.Generic (class Generic, gEq)
import Prelude (class Eq, (>>=), ($), pure)
import Data.Foreign.Class (read, readProp, class IsForeign)
import Data.Either (Either)
import Control.Monad.Eff.Exception (Error)
import Data.Foreign.Class (readEitherR)

data Action =
    ReadComplete Blacklist
  -- link 
  | LinkChange PE.FormEvent
  | LinkDragEnter PE.MouseEvent
  | LinkDragLeave PE.MouseEvent
  | LinkIncorrectFormat
  | LinkAjaxFetch
  | LinkParse String
  -- name
  | NameChange PE.FormEvent
  | AutoNameChange String NickCheckStatus
  -- note
  | NoteChange PE.FormEvent
  -- date
  | DateChange DateTime
  | UpdateCurrentTime

  -- crude operations on the list
  | AddEntry
  | AddDeleteQueue BlacklistEntry
  | RemoveDeleteQueue BlacklistEntry
  | WriteItem
  | WriteComplete
  | FlushDeleteQueue
  | AbortDeleteQueue

  -- represents of the ajax call 
  -- and the parsing result
data NickCheckStatus =
  Idle
  | Checking
  | Success
  | ParseFail
  | NetworkFail

derive instance genericNickCheckStatus :: Generic NickCheckStatus
instance  eqNickCheckStatus :: Eq NickCheckStatus where
  eq = gEq

 --  ui states and webworker filename
type State =
  { list :: Blacklist
  , deleteQueue :: Blacklist
  , entry :: BlacklistEntry
  , delBtnDisabled :: Boolean
  , isloading :: NickCheckStatus
  , linkInputDisabled :: Boolean
  , parseWorkerFilename :: String -- this is readonly.
  }

newtype Message = Message {message :: String}
instance isForeignMessage :: IsForeign Message where
  read obj = readProp "message" obj >>= \message -> pure $ Message {message}
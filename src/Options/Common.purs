module Options.Common
  ( Action(..)
  , NickCheckStatus(..)
  , State(..)
  , Message(..)
  ) where

import Common
import Pux.Html.Events as PE
import Control.Monad.Eff.Exception (Error)
import Data.DateTime (DateTime)
import Data.Either (Either)
import Data.Foreign.Class (read, readProp, class IsForeign)
import Data.Foreign.Class (readEitherR)
import Data.Generic (class Generic, gEq)
import Prelude (class Eq, (>>=), ($), pure)
import Text.Parsing.Parser.String (class StringLike)

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
  -- color
  | TextColorChange PE.FormEvent
  | BackColorChange PE.FormEvent
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
  , textColor :: String
  , backColor :: String
  , parseWorkerFilename :: String -- this is readonly.
  }

newtype Message = Message {message :: String}
instance isForeignMessage :: IsForeign Message where
  read obj = readProp "message" obj >>= \message -> pure $ Message {message}


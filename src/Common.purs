module Common
    ( AppEffects
    , ChromeEffects
    , Blacklist(..)
    , BlacklistEntry(..)
    , ExampleKey(..)
    , atStateLink
    , atStateName
    , atStateNote
    , atStateDate
    , atBlackUsers
    , atBlackUserEntries
    , atEntry
    , atList
    , atLink
    , atDelBtnDisabled
    , atLinkInputDisabled
    , atIsloading
    , atName
    , atNote
    , atDate
    , blacklistKey
    , defaultList
    , defaultEntry
    , readLocalStorage
    , writeLocalStorage
    , link
    , atDeleteQueue
    , atDeleteQueueBlackUsers
    ) where

import Data.Lens
import Data.Either as Either
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Now (NOW)
import DOM (DOM)
import Data.Generic (class Generic, gEq)
import Data.Maybe (fromMaybe)
import DOM.WebStorage (STORAGE, getItem, setItem, getLocalStorage)
import Prelude (bind, pure, ($), class Eq, (>>>), Unit)
import Control.Monad.Eff (Eff)
import Data.Profunctor.Strong (class Strong)
import Data.Profunctor.Choice (class Choice)
import Network.HTTP.Affjax (AJAX)
import ChromeAPI (Chrome)
import Control.Monad.Aff.AVar
import WebWorker (OwnsWW)


type ChromeEffects eff = Eff ( chrome :: Chrome
                             , dom :: DOM
                             , storage :: STORAGE
                             , console :: CONSOLE | eff)
type AppEffects = ( dom :: DOM
                  , console::CONSOLE
                  , now :: NOW
                  , ajax :: AJAX
                  , avar :: AVAR
                  , ownsww :: OwnsWW
                  , storage::STORAGE)

newtype BlacklistEntry =
        BlacklistEntry { link :: String
                       , name :: String
                       , note :: String
                       , date :: String
                       }

derive instance genericBlacklistEntry :: Generic BlacklistEntry

instance eqBlacklistEntry :: Eq BlacklistEntry where
  eq = gEq

newtype Blacklist = Blacklist { blackUsers :: Array  BlacklistEntry }

derive instance genericBlacklist :: Generic Blacklist

data ExampleKey a = BlacklistEntryKey
                  | BlacklistKey
derive instance genericExampleKey :: Generic (ExampleKey a)

blacklistKey :: ExampleKey Blacklist
blacklistKey = BlacklistKey

defaultEntry :: BlacklistEntry
defaultEntry = BlacklistEntry { link:"", name:"",note:"",date:"" }

defaultList :: Blacklist
defaultList = Blacklist { blackUsers :[] }

readLocalStorage :: forall e. Eff (dom :: DOM, storage :: STORAGE | e) Blacklist
readLocalStorage = do
    localStorage <- getLocalStorage
    storedList <- getItem localStorage blacklistKey
    pure $ fromMaybe defaultList storedList

writeLocalStorage :: forall e. Blacklist-> Eff (dom :: DOM, storage :: STORAGE | e) Unit
writeLocalStorage blacklist = do
  localStorage <- getLocalStorage
  setItem localStorage blacklistKey blacklist


-- combined lens accessors

type StateEntryStringAccessor =
  forall r p. (Strong p, Choice p) =>
  p String String
  -> p { entry :: BlacklistEntry | r } { entry :: BlacklistEntry | r }

atBlackUsers ::
  forall r p. (Strong p, Choice p) =>
  p (Array BlacklistEntry) (Array BlacklistEntry)
  -> p { list :: Blacklist | r } { list :: Blacklist | r }
atBlackUsers = blackUsers >>> _Blacklist >>> list

atDeleteQueueBlackUsers ::
  forall r p. (Strong p, Choice p) =>
  p (Array BlacklistEntry) (Array BlacklistEntry)
  -> p { deleteQueue :: Blacklist | r } { deleteQueue :: Blacklist | r }
atDeleteQueueBlackUsers = blackUsers >>> _Blacklist >>> deleteQueue

atStateLink :: StateEntryStringAccessor
atStateLink = link >>> _BlacklistEntry >>> entry

atStateName :: StateEntryStringAccessor
atStateName = name >>> _BlacklistEntry >>> entry

atStateNote :: StateEntryStringAccessor
atStateNote = note >>> _BlacklistEntry >>> entry

atStateDate :: StateEntryStringAccessor
atStateDate = date >>> _BlacklistEntry >>> entry

atBlackUserEntries = traversed  >>> blackUsers >>> _Blacklist

type EntryStringAccessor =
  forall p. (Strong p, Choice p) =>
  p String String
  -> p BlacklistEntry BlacklistEntry

atLink :: EntryStringAccessor
atLink = link >>> _BlacklistEntry

atName :: EntryStringAccessor
atName = name >>> _BlacklistEntry

atNote :: EntryStringAccessor
atNote = note >>> _BlacklistEntry

atDate :: EntryStringAccessor
atDate = date >>> _BlacklistEntry


-- All codes below this line can be generated from 
-- https://github.com/paf31/purescript-derive-lenses

atList ::
  forall p a b r. (Strong p) =>
  p a b
  -> p { list :: a | r } { list :: b | r }
atList = list

atEntry ::
  forall p a b r. (Strong p) =>
  p a b
  -> p { entry :: a | r } { entry :: b | r }
atEntry = entry

atDelBtnDisabled ::
  forall p a b r. (Strong p) =>
  p a b
  -> p { delBtnDisabled :: a | r } { delBtnDisabled :: b | r }
atDelBtnDisabled = delBtnDisabled

atLinkInputDisabled ::
  forall p a b r. (Strong p) =>
  p a b
  -> p { linkInputDisabled :: a | r } { linkInputDisabled :: b | r }
atLinkInputDisabled = linkInputDisabled

atDeleteQueue ::
  forall p a b r. (Strong p) =>
  p a b
  -> p { deleteQueue :: a | r } { deleteQueue :: b | r }
atDeleteQueue = deleteQueue

atIsloading ::
  forall p a b r. (Strong p) =>
  p a b
  -> p { isloading :: a | r } { isloading :: b | r }
atIsloading = isloading

delBtnDisabled :: forall a b r. Lens { "delBtnDisabled" :: a | r } { "delBtnDisabled" :: b | r } a b
delBtnDisabled = lens _."delBtnDisabled" (_ { "delBtnDisabled" = _ })

linkInputDisabled :: forall a b r. Lens { "linkInputDisabled" :: a | r } { "linkInputDisabled" :: b | r } a b
linkInputDisabled = lens _."linkInputDisabled" (_ { "linkInputDisabled" = _ })

deleteQueue :: forall a b r. Lens { "deleteQueue" :: a | r } { "deleteQueue" :: b | r } a b
deleteQueue = lens _."deleteQueue" (_ { "deleteQueue" = _ })

list :: forall a b r. Lens { "list" :: a | r } { "list" :: b | r } a b
list = lens _."list" (_ { "list" = _ })

entry :: forall a b r. Lens { "entry" :: a | r } { "entry" :: b | r } a b
entry = lens _."entry" (_ { "entry" = _ })

link :: forall a b r. Lens { "link" :: a | r } { "link" :: b | r } a b
link = lens _."link" (_ { "link" = _ })

isloading :: forall a b r. Lens { "isloading" :: a | r } { "isloading" :: b | r } a b
isloading = lens _."isloading" (_ { "isloading" = _ })


name :: forall a b r. Lens { "name" :: a | r } { "name" :: b | r } a b
name = lens _."name" (_ { "name" = _ })

note :: forall a b r. Lens { "note" :: a | r } { "note" :: b | r } a b
note = lens _."note" (_ { "note" = _ })

date :: forall a b r. Lens { "date" :: a | r } { "date" :: b | r } a b
date = lens _."date" (_ { "date" = _ })

_BlacklistEntry :: Prism' BlacklistEntry
                     { link :: String
                     , name :: String
                     , note :: String
                     , date :: String
                     }
_BlacklistEntry = prism BlacklistEntry unwrap
  where
    unwrap (BlacklistEntry x) = Either.Right x

blackUsers :: forall a b r. Lens { "blackUsers" :: a | r } { "blackUsers" :: b | r } a b
blackUsers = lens _."blackUsers" (_ { "blackUsers" = _ })

_Blacklist :: Prism' Blacklist
                { blackUsers :: Array BlacklistEntry
                }
_Blacklist = prism Blacklist unwrap
  where
    unwrap (Blacklist x) = Either.Right x

module Content where

import Prelude (Unit,bind,(<>),(>>=))
import Data.Foldable (for_)
import Control.Monad.Eff.JQuery (remove, select, setText, find, css, ready)
import JQuery (parents)
import ChromeAPI (Command(..), ResponseData(..), sendMessage)
import Common (ChromeEffects)

import Control.Monad.Eff.Console (logShow)

type UserName = String
data BLockMethod = BLIND | REMOVE

type BlindConfig = { pointer_events :: String
                   , cursor :: String
                   , opacity :: String
                   , color   :: String
                   , font_style    :: String
                   , replacedText :: String
                   }

blindUserItem :: forall eff. BlindConfig -> UserName -> ChromeEffects eff Unit
blindUserItem config href = do
    item <- select groupSelector >>= find (nickSelectorByHref href)
                                 >>= parents itemSelector
    heading <- find headingSelector item
    avatar  <- find avatarSelector item
    article  <- find articleSelector item
    for_ [heading, avatar, article] blindTag
    where
      blindTag tag = do
        setText config.replacedText tag
        css config tag
        -- setProp "href" "..." tag

removeUserItem :: forall eff. UserName -> ChromeEffects eff Unit
removeUserItem href = do
    item <- select groupSelector >>= find (nickSelectorByHref href)
                                 >>= parents itemSelector
    remove item


groupSelector :: String
groupSelector = ".list-group"

nickSelectorByHref :: UserName -> String
nickSelectorByHref href = ".nickname[href='" <> href <> "']"

itemSelector :: String
itemSelector = ".list-group-item"

headingSelector :: String
headingSelector  = "h5>a"

avatarSelector :: String
avatarSelector  = ".avatar-info>a"

articleSelector :: String
articleSelector = "article"

blindConfig :: BlindConfig
blindConfig = { pointer_events: "auto"
    , cursor: "auto"
    , opacity:"0.3"
    , color: "lightgrey"
    , font_style: "italic"
    , replacedText: "blocked"
    }

command :: Command
command = Command { method : "getLocalStorage"
                  , key :"blacklist"}

method :: BLockMethod
method = BLIND

handleResponse :: forall eff. ResponseData -> ChromeEffects eff Unit
handleResponse (ResponseData resp) = do
    let users  = resp.data
    logShow users
    case method of
      BLIND  -> for_ users (blindUserItem blindConfig)
      REMOVE -> for_ users (removeUserItem)


main :: forall eff. ChromeEffects eff Unit
main = do
  ready ( sendMessage command handleResponse )

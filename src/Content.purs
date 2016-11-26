module Content where

import Prelude (Unit,bind,(<>),(>>=), ($), (==), when)
import Data.Foldable (for_)
import Control.Monad.Eff.JQuery (remove, select, setText, find, css, ready)
import JQuery (parents, cssp)
import ChromeAPI (sendMessage)
import ChromeMessages (Command(..), ResponseData(..))
import Common (ChromeEffects, BlacklistEntry, atLink, atBlockText, atTextColor, atBackColor)
import Data.Lens (view) as L 

import Control.Monad.Eff.Console (logShow)

data BLockMethod = BLIND | REMOVE

type BlindConfig = { pointer_events :: String
                   , cursor :: String
                   , opacity :: String
                   , color   :: String
                   , font_style    :: String
                   , replacedText :: String
                   }

blindUserItem :: forall eff. BlindConfig -> BlacklistEntry -> ChromeEffects eff Unit
blindUserItem config entry = do
    item <- select groupSelector >>= find (nickSelectorByHref $ L.view atLink entry)
                                 >>= parents itemSelector
    heading <- find headingSelector item
    avatar  <- find avatarSelector item
    article  <- find articleSelector item
    for_ [heading, avatar, article] blindTag
    where
      blindTag tag = do
        let textColor = L.view atTextColor entry 
            backColor = L.view atBackColor entry
        cssp { color : textColor, background_color: backColor } tag
        when (L.view atBlockText entry ==  "true") (setText config.replacedText tag) 
        -- setProp "href" "..." tag

removeUserItem :: forall eff. BlacklistEntry -> ChromeEffects eff Unit
removeUserItem entry = do
    item <- select groupSelector >>= find (nickSelectorByHref $ L.view atLink entry)
                                 >>= parents itemSelector
    remove item

groupSelector :: String
groupSelector = ".list-group"

nickSelectorByHref :: String -> String
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
    -- logShow users
    case method of
      BLIND  -> for_ users (blindUserItem blindConfig)
      REMOVE -> for_ users (removeUserItem)


main :: forall eff. ChromeEffects eff Unit
main = do
  ready ( sendMessage command handleResponse )

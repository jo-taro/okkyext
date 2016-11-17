module Parser
  ( trimUserLink
  , trimUserNick
  , userPathPrefix
  , nickNameP
  , nickOpenTag
  , nickCloseTag
  , anyStr
  ) where


import Data.Either (Either(..))
import Data.List (List, toUnfoldable, foldr)
import Data.String (fromCharArray, null)
import Prelude (bind, (<>), ($), pure, (<<<))
import Text.Parsing.StringParser (Parser, runParser)
import Text.Parsing.StringParser.Combinators (many1, manyTill, lookAhead)
import Text.Parsing.StringParser.String (anyDigit, string, anyChar, noneOf)
import Control.Alternative ((<|>))
import Data.Maybe (Maybe(..))
import Data.Either
import Control.Monad.Eff.Exception (Error, error)

nickOpenTag :: String
nickOpenTag = "<h2 class=\"pull-left\">"

nickCloseTag :: String
nickCloseTag = "</h2>"

nickOnlyP :: Parser String
nickOnlyP = do
  string nickOpenTag
  nick <- many1 (noneOf ['<'])
  string nickCloseTag
  pure $ (fromCharArray <<< toUnfoldable) nick

lc2Str :: List Char -> String
lc2Str = fromCharArray <<< toUnfoldable

anyStr :: Parser String
anyStr = do
  anyChar
  pure $ ""

nickNameP :: Parser String
nickNameP = do
  nickOnly <- many1 (nickOnlyP <|> anyStr)
  let nick = foldr (<>) "" nickOnly
  pure $ nick


trimUserNick :: String -> Either Error String
trimUserNick input = do

--  FIXME: manyTill parser combinator blows up the stack.
--         how can we immplement this  with TailRec class? 
  case runParser nickNameP input of
    Left err -> Left $ error "닉네임을 태그를 찾을 수 없습니다" 
    Right res -> if null res
                   then Left $ error "닉네임을 태그를 찾을 수 없습니다" 
                   else Right res

userPathPrefix :: String
userPathPrefix = "/user/info/"

userDigitP :: Parser (List Char)
userDigitP = many1 anyDigit

userPathPrefixP :: Parser String
userPathPrefixP = string userPathPrefix

okkyUserP :: Parser String
okkyUserP = do
  manyTill anyChar (lookAhead userPathPrefixP)
  prefix <- userPathPrefixP
  digit <- userDigitP
  pure $ prefix <> (fromCharArray <<< toUnfoldable) digit

trimUserLink ::  String -> Maybe String
trimUserLink input = do
  case runParser okkyUserP input of
    Left err ->  Nothing
    Right res -> Just res

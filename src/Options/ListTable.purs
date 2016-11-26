module Options.ListTable
  ( renderUserList
  ) where

import Pux.Html hiding (style)
import Pux.Html.Attributes
import Pux.Html.Events as PE
import Data.Lens as L
import Common
import Prelude (($), (<>), (<$>), const, (==))
import Options.Common
import Data.Tuple (Tuple(Tuple))
import Data.Array (elem)


-- List table component at the bottom 
renderUserList :: State -> Html Action
renderUserList state = do
  div
    [ className "container"]
    [
      table
        [ className "table table-hover"
        , style $ [Tuple "min-width" "420px"]]
        [ thead
            []
            [ tr
                []
                [ th [ nameStyle ] [ text "사용자 정보" ]
                , th [ blockStyle ] [ text "차단" ]
                , th [ colorStyle ] [ text "색상" ]
                , th [ noteStyle ] [ text "메모" ]
                , th [ dateStyle ] [ text "기록시각" ]
                , th [] [ text "" ]
                ]
            ]
        , tbody [] $  (renderUser state) <$> (L.view atBlackUsers state)
        ]
    ]

renderUser :: State -> BlacklistEntry -> Html Action
renderUser state entry =
  let selected = elem entry (L.view atDeleteQueueBlackUsers state)
  in  tr
        [ ]
        [
          td [ nameStyle ]
              [ text $ L.view atName entry
              , br [] []
              , a
                [ href $ "http://okky.kr" <> L.view atLink entry ]
                [text $ L.view atLink entry]
              ]
        , td
            [blockStyle]
            [
              text $ if L.view atBlockText entry == "true" then "예" else ""
            ]
        , td 
            [ colorStyle] 
            [ input [ type_ "color"
                    , disabled true
                    , value $ L.view atTextColor entry ] []
            , input [ type_ "color"
                    , disabled true
                    , value $ L.view atBackColor entry ] []
            ]
        , td [ noteStyle] [ text $ L.view atNote entry ]
        , td [ dateStyle] [ text $ L.view atDate entry ]
        , td
            []
              if selected
              then
                [ 
                  button
                  [ className "btn btn-info"
                  , PE.onClick (const (RemoveDeleteQueue entry)) ]
                  [ text "선택 취소" ]
                ]
              else
                [ 
                  button
                  [ className "btn btn-warning"
                  , PE.onClick (const (AddDeleteQueue entry)) ]
                  [ text "삭제 선택"] 
                ]
        ]

nameStyle ::Attribute Action
nameStyle = style $ [ Tuple "width" "20%" ]

blockStyle ::Attribute Action
blockStyle = style $ [ Tuple "width" "10%" ]

colorStyle ::Attribute Action
colorStyle = style $ [ Tuple "width" "5%" ]

noteStyle ::Attribute Action
noteStyle = style $ [ Tuple "width" "40%" ]

dateStyle ::Attribute Action
dateStyle = style $ [ Tuple "width" "25%" ]


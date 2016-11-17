module Options.ToolBar 
  ( renderToolBar
  ) where

import Pux.Html hiding (style)
import Pux.Html.Attributes
import Pux.Html.Events as PE
import Data.Lens as L
import Common
import Prelude (($), const)
import Options.Common
import Data.Tuple (Tuple(Tuple))

-- Upper components
renderToolBar :: State -> Html Action
renderToolBar state = do
  div
    [ style $ [ Tuple "border" "1px solid black"
              , Tuple "margin" "10px"
              , Tuple "padding" "10px"
              , Tuple "text-align" "center"
              , Tuple "min-width" "420px"]
    ]
    [ div
        [ className "btn-group", attr "role" "group"]
        [ button
            [ PE.onClick (const FlushDeleteQueue)
            , className "btn btn-danger"
            , disabled (L.view atDelBtnDisabled state) ]
            [ text "선택 삭제"]
        , button
            [ PE.onClick (const AbortDeleteQueue)
            , className "btn btn-success"
            , disabled (L.view atDelBtnDisabled state) ]
            [ text "모두 취소"]
        ]
    ]

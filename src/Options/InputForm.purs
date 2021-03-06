module Options.InputForm 
  ( renderInsertForm
  ,  colorPicker
  ) where

import Pux.Html hiding (style)
import Pux.Html.Attributes hiding (label,form)
import Pux.Html.Events as PE
import Data.Lens as L
import Common
import Prelude ((<>), ($), negate, const, (/=), (==))
import Options.Common
import Data.Tuple (Tuple(Tuple))
-- import SketchExample as S


-- Input form components
renderInsertForm :: State -> Html Action
renderInsertForm state = do
  div
    [ className "container"
    , style $ [Tuple "min-width" "420px"]
    ]
    [ form
        [ name "add"
        , PE.onSubmit (const AddEntry)
        , className "form-horizontal" ]

        [ linkRow state
        , nameRow state
        , noteRow state
        , colorRow state
        , dateRow state
        , addRow state
        ]
    ]


linkRow :: State -> Html Action
linkRow state =
  div
    [ className "form-group" ]
    [ label
        [ attr "for" "inputLink", className "col-sm-2 control-label"]
        [ text "링크"]
    , div
        [ className "col-sm-10" ]
        [ input
            [ type_ "text", value (L.view atStateLink state)
            , placeholder "사용자의 주소를 마우스로 끌어놓아 주세요."
            , className "form-control"
            , id_ "inputLink"
            , readOnly (L.view atLinkInputDisabled state)
            , PE.onChange LinkChange
            , PE.onDragEnter LinkDragEnter
            , PE.onDragLeave LinkDragLeave
            , tabIndex (-1)
            ] 
            []
        ]
    ]
  
nameRow :: State -> Html Action  
nameRow state =
  div
    [ className "form-group" ]
    [ label
        [ attr "for" "inputName", className "col-sm-2 control-label"]
        [ text "별칭"]
    , div
        [ className "col-sm-10" ]
        [ div
            [ className "input-group"]
            [ span
                [ className "input-group-addon"
                , style [Tuple "padding" "0rem 0.75rem 0rem 0.75rem"]
                , id_"basic-addon1"
                ]
                [ img [ src (checkStatusImage $ L.view atIsloading state) ][]]
            , input
                [ type_ "text", value (L.view atStateName state)
                , placeholder "자동 확인"
                , className "form-control"
                , attr "aria-describedby" "basic-addon1"
                , id_ "inputName"
                , readOnly true
                , PE.onChange NameChange
                , tabIndex (-1)
                ]
                []
            ]
        ]
    ]
    where
      checkStatusImage :: NickCheckStatus -> String
      checkStatusImage s =
        case s of
          Idle -> "android_info_24px.svg"
          Checking -> "loader.svg"
          Success -> "android_check_24px.svg"
          ParseFail -> "android_no_24px.svg"
          NetworkFail -> "android_off_24px.svg"



noteRow :: State -> Html Action 
noteRow state =
  div
    [ className "form-group" ]
    [ label
        [ attr "for" "inputNote", className "col-sm-2 control-label"]
        [ text "메모" ]
    , div
        [ className "col-sm-10" ]
        [ input
            [ type_ "text", value (L.view atStateNote state)
            , placeholder ""
            , className "form-control"
            , id_ "inputNote"
            , readOnly false
            , PE.onChange NoteChange
            , autoFocus true
            ] 
            []
        ]
    ]

dateRow :: State -> Html Action
dateRow state =
  div
    [ className "form-group" ]
    [ label
        [ attr "for" "inputDate", className "col-sm-2 control-label"]
        [ text "시간"]
    , div
        [ className "col-sm-10" ]
        [ input
            [ type_ "text", value (L.view atStateDate state)
            , className "form-control"
            , id_ "inputDate"
            , readOnly true
            , tabIndex (-1)
            ]
            []
        ]
    ]

colorRow :: State -> Html Action
colorRow state =
  let blockText = L.view atStateBlockText state == "true"
  in
      div !
        className "form-group"
        ##
        [ label
            [ attr "for" "checkBlock", className "col-sm-2 control-label"]
            [ text "차단"]
        , div 
            [ className "col-sm-1"]
            [ input 
                [ className "form-control col-sm-1"
                , style [ Tuple "outline" "none"
                        , Tuple "border" "none"
                        , Tuple "-webkit-box-shadow" "none"
                        , Tuple "-moz-box-shadow" "none"
                        , Tuple "box-shadow" "none"
                        , Tuple "margin" "0rem"
                        ]
                , type_ "checkbox"
                , id_ "checkBlock"
                , PE.onChange BlockTextChange
                , checked $ blockText
                ] 
                []
            ]
        ]  <> (colorPicker state)  

colorPicker :: State -> Array (Html Action)
colorPicker state =
      [ label
          [ attr "for" "inputColors"
          , className "col-sm-1 control-label"
          ]
          [ text "색상"]
      , div
          [ className "col-sm-2"
          , style [ Tuple "text-align" "center"
                  ]
          ]
          [ div 
              [ id_ "inputColors"
              , className "btn-group"
              ]
              [ span
                  [ className "btn"
                  , style [ Tuple "padding" "0rem"
                          , Tuple "margin" "0.5rem 0rem 0.5rem 0rem"
                          ] 
                  ] 
                  [ input 
                      [ type_ "color"
                      , value (L.view atStateTextColor state)
                      , PE.onChange TextColorChange 
                      ] [] 
                  ]
              , span
                  [ className "btn"
                  , style [ Tuple "padding" "0rem"
                          , Tuple "margin" "0.5rem 0rem 0.5rem 0rem"
                          ]
                  ]
                  [ input 
                      [ type_ "color"
                      , value (L.view atStateBackColor state)
                      , PE.onChange BackColorChange
                      ] []
                  ]
              ]
          ]
      ] 

addRow :: State -> Html Action
addRow state =
  div [className "form-group"]
    [ div [className "col-sm-offset-2 col-sm-10"]
        [ button
            [ type_ "submit"
            , className "btn btn-primary "
            , disabled (L.view atIsloading state /= Success)
            ]
            [ text "추가" ]
        ]
    ]


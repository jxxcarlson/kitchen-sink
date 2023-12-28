module Pages.Home exposing (view)

import Element exposing (Element)
import Element.Font
import Html.Attributes
import MarkdownThemed
import Pages.Parts
import Theme
import Types exposing (..)


view : LoadedModel -> Element FrontendMsg_
view model =
    let
        sidePadding =
            if model.window.width < 800 then
                24

            else
                60
    in
    Element.column
        [ Element.width Element.fill ]
        [ Element.column
            [ Element.spacing 50
            , Element.width Element.fill
            , Element.paddingEach { left = sidePadding, right = sidePadding, top = 0, bottom = 24 }
            ]
            [ Pages.Parts.header { window = model.window, isCompact = False }
            , Element.column
                [ Element.width Element.fill, Element.spacing 40 ]
                [ Element.column Theme.contentAttributes [ content1 ]
                , Element.column
                    Theme.contentAttributes
                    [ MarkdownThemed.renderFull "# Last year's sponsors"
                    , sponsors model.window
                    ]
                , Element.column
                    [ Element.width Element.fill
                    , Element.spacing 24
                    , Element.htmlAttribute (Html.Attributes.id ticketsHtmlId)
                    ]
                    [ Element.el Theme.contentAttributes content2
                    , Element.el Theme.contentAttributes content3
                    ]
                ]
            ]
        , Theme.footer
        ]


ticketsHtmlId =
    "tickets"


content1 : Element msg
content1 =
    """


Did you attend Elm Camp 2023? We're [open to contributions on Github](https://github.com/elm-camp/website/edit/main/src/Camp23Denmark/Artifacts.elm)!
        """
        |> MarkdownThemed.renderFull


content2 : Element msg
content2 =
    """

# Opportunity grants

Last year, we were able to offer opportunity grants to cover both ticket and travel costs for a number of attendees who would otherwise not have been able to attend. We're still working out the details for next year's event, but we hope to be able to offer the same opportunity again.

**Thanks to Concentric and generous individual sponsors for making the Elm Camp 2023 opportunity grants possible**.

# 2024 Organisers

Elm Camp is a community-driven non-profit initiative, organised by enthusiastic members of the Elm community.

"""
        ++ organisers2024
        |> MarkdownThemed.renderFull


organisers2024 =
    """
🇬🇧 Katja Mordaunt – Uses web tech to help improve the reach of charities, artists, activists & community groups. Industry advocate for functional & Elm. Co-founder of [codereading.club](https://codereading.club/)

🇺🇸 James Carlson – Developer of [Scripta.io](https://scripta.io), a web publishing platform for technical documents in mathematics, physics, and the like. Currently working for [exosphere.app](https://exosphere.app), an all-Elm cloud-computing project

🇬🇧 Mario Rogic – Organiser of the [Elm London](https://meetdown.app/group/37aa26/Elm-London-Meetup) and [Elm Online](https://meetdown.app/group/10561/Elm-Online-Meetup) meetups. Groundskeeper of [Elmcraft](https://elmcraft.org/), founder of [Lamdera](https://lamdera.com/).

🇩🇪 Johannes Emerich – Works at [Dividat](https://dividat.com/en), making a console with small games and a large controller. Remembers when Elm demos were about the intricacies of how high Super Mario jumps.

🇺🇸 Wolfgang Schuster – Author of [Elm weekly](https://www.elmweekly.nl/), hobbyist and professional Elm developer. Currently working at [Vendr](https://www.vendr.com/).

🇬🇧 Hayleigh Thompson – Terminally online in the Elm community. Competitive person-help. Developer relations engineer at [xyflow](https://www.xyflow.com/).
"""


content3 =
    """
# Sponsorship options

Sponsoring Elm Camp gives your company the opportunity to support and connect with the Elm community. Your contribution helps members of the community to get together by keeping individual ticket prices at a reasonable level.

If you're interested in sponsoring please get in touch with the team at [team@elm.camp](mailto:team@elm.camp).

# Something else?

Problem with something above? Get in touch with the team at [team@elm.camp](mailto:team@elm.camp)."""
        |> MarkdownThemed.renderFull


sponsors : { window | width : Int } -> Element msg
sponsors window =
    let
        asImg { image, url, width } =
            Element.newTabLink
                [ Element.width Element.fill ]
                { url = url
                , label =
                    Element.image
                        [ Element.width
                            (Element.px
                                (if window.width < 800 then
                                    toFloat width * 0.7 |> round

                                 else
                                    width
                                )
                            )
                        ]
                        { src = "/sponsors/" ++ image, description = url }
                }
    in
    [ asImg { image = "vendr.png", url = "https://www.vendr.com/", width = 250 }
    , asImg { image = "concentrichealthlogo.svg", url = "https://concentric.health/", width = 250 }
    , asImg { image = "logo-dividat.svg", url = "https://dividat.com", width = 170 }
    , asImg { image = "lamdera-logo-black.svg", url = "https://lamdera.com/", width = 200 }
    , asImg { image = "scripta.io.svg", url = "https://scripta.io", width = 200 }
    , asImg { image = "bekk.svg", url = "https://www.bekk.no/", width = 200 }
    , Element.newTabLink
        [ Element.width Element.fill ]
        { url = "https://www.elmweekly.nl"
        , label =
            Element.row [ Element.spacing 10, Element.width (Element.px 200) ]
                [ Element.image
                    [ Element.width
                        (Element.px
                            (if window.width < 800 then
                                toFloat 60 * 0.7 |> round

                             else
                                60
                            )
                        )
                    ]
                    { src = "/sponsors/" ++ "elm-weekly.svg", description = "https://www.elmweekly.nl" }
                , Element.el [ Element.Font.size 24 ] <| Element.text "Elm Weekly"
                ]
        }
    , asImg { image = "cookiewolf-logo.png", url = "", width = 220 }
    ]
        -- |> List.map asImg
        |> Element.wrappedRow [ Element.spacing 32 ]

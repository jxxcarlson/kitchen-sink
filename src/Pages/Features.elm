module Pages.Features exposing (view)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    """
# Features

The kitchen sink app provides the features listed below.
Some features are still in-progress.  If there is a feature you
think should be part of this template app, please let me know.
I am jxxcarlsn  on slack, discourse, discord, and email (gm..l).

*I am looking for good port and custom element examples, especially
the latter.*

- Page routing
- Stripe (See *the *Purchase** tab)
- Ports (Stripe, Chirp and Copy Pi buttons on the home page)
- Basic admin page (started, accessible if the user is the signed-in admin)
- User module (mock-up of user sign-in/up/out stuff, see the *Sign In* tab)
- Authentication (started by rob_soko (Rob Sokolowski))
- UUIDs (generate on backend and provide as service)
- Custom elements (live local time display. *I need something more
  substantial. Suggestions, code, and help are welcome.  A calendar element would be
  especially nice.*)
- RPC (Stripe interface, example of a backend service to post and get key-value pairs)
- Markdown (used in this document and others)

The template is based on a stripped-down version of
Mario Rogic's [Elm Camp Website](https://github.com/elm-camp/website) code.
For additional information, see the **Notes** tab.

## sjalq's list


### Backend Data examples

We have the field `keyValueStore : Dict.Dict String String` of the backend model.
Data is inserted and retrieved via RPC calls.  See the **RPC Example** section
in the **Notes** tab.

### Pages with routing.

  All of the tabs in the menu bar/header of this app are pages with routing.

### A reused component on two pages to demonstrate composability

??

### User + rights management

??

### A simplified OAuth implementation

**Via custom code, not the Auth modules. Wire in for Google**

Rob Sokolowski (rob_soko) has started an OAuth implementation.  We will have more to
say abou this later.

### Rights gating to a page.

 The Admin page is only accessible to the signed-in admin.
 Gating is handled in `loadedView : LoadedModel -> Element FrontendMsg`
 by the `AdminRoute` case:

 ```
 loadedView : LoadedModel -> Element FrontendMsg
 loadedView model =
     case model.route of

     ...

     AdminRoute ->
         if Predicate.isAdmin model.currentUser then
             Pages.Parts.generic model Pages.Admin.view

         else
             Pages.Parts.generic model Pages.Home.view
     ...
```

### An outbound HTTP example

See the **Weather** example on the home (Kitchen Sink) page.

### An incoming RPC example

See `putKeyValuePair` and `getKeyValuePair` in section **RPC Example** in
tab **Notes.**




### An example of using ports

See the **Copy Pi** and **Chirp** buttons on the home page and the explanation thereof
in the **Ports** section of the **Notes** tab.


### An example of web component (custom element)

See the live time and zone display in the home (Kitchen Sink) page.
Documentation in the **Custom Elements** section of the **Notes** tab.
Missing: at least one more example.


"""
        |> MarkdownThemed.renderFull

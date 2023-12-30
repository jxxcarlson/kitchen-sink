module Pages.Notes exposing (view)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    """
#  Notes

The Kitchen Sink Template is a template for creating Lamdera apps
which has a lot of features already set up for you.

## Adding a new page

Suppose that you want to add a new page for notes to your app.
You must first set up and configure a the route for the page.
Define a new variant `Notes` for the type
`Route` in `Routes.elm`.
Then follow the compiler errors to update the functions
`decode : Url -> Route`
and
`encode : Route -> String` in that module.

Next, add a new module `Pages.Notes`, put some
draft content in it, import it into module
`Frontend`, and add an entry in the
function `Frontend.update` to handle the
new route.

If you want to add a link to the new page in the
footer, add something like the below to
`Pages.Parts.footer`:

```elm
Element.link [] { url = Route.encode Notes, label = Element.text "Notes" }
```

Another possibility is to add a link to `Pages.parts.header`:

## Ports: sending a message to JavaScript

The **Chirp** button you see on the home page plays a "chirp" sound
when you click it. This is done by sending a message to JavaScript
via ports.  Here are the places to look to see how this is done:

- `elm-pkg-js/play-sound.js` is the JavaScript code that plays the sound.

- In `elm-pkg-js-includes.js` there is mandatory code needed for ports to work in production.

- In module `Ports`, one has the function `port playSound : Json.Encode.Value -> Cmd msg`
  which sends data to Javascript world.

- This function is called in `Frontend.update` when the message `Chirp` is received.
  The handler for this message is
  `Chirp -> ( model, Ports.playSound (Json.Encode.string "chirp.mp3") )`. Clicking
  on the "Chirp" button sends the message `Chirp`.

- There is a file `chirp.mp3` in the `public` directory.  This is the
audio file that is played.

Look in the `elm-pkg-js` directory and the module `Ports` for more examples.


## Stripe

*((This section and the supporting code in the template is a work in progress.
I will remove this paragraph when the work is done.  In the meantime, if you
suggestions, comments, or suggestions, let me know: jxxcarlson everywhere: slack, discourse, gmail))*

To use Stripe you will need to set up a Stripe account, get a Stripe API key,
and set up products and prices.  For the latter, you can use either the Stripe CLI or
the Product Dashboard.  To to [stripe.com](https://stripe.com) to set up your account.


**Articles**

- [Stripe API Reference](https://stripe.com/docs/api)

- [How to products and prices with the dashboard](https://support.stripe.com/questions/how-to-create-products-and-prices)


**Links**

- [Stripe Dashboard](https://dashboard.stripe.com/)

- [Product Dashboard](https://dashboard.stripe.com/products)


**Stripe CLI, selected commands:**

To install the Stripe CLI, to [here](https://stripe.com/docs/stripe-cli#install).

- `stripe login` logs you in to your Stripe account

- `stripe resources` lists all the resources in your Stripe account, e.g., products and prices

- `stripe products` usage: `stripe products <operation> [parameters...]`

- `stripe products --help` gives help for the 'products' resource

- `stripe products create` creates a product, use `--help for details`

- `stripe products list` lists all your products

- `stripe prices create` creates a price, use `--help for details`

- `stripe prices list` lists all your prices

- `stripe logs tail` tails the logs for your Stripe account

"""
        |> MarkdownThemed.renderFull

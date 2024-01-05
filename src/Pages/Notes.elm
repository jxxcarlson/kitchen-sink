module Pages.Notes exposing (view)

import Element exposing (Element)
import MarkdownThemed
import Types exposing (..)


view : LoadedModel -> Element msg
view model =
    """
#  Notes

The **Kitchen Sink Template** is a template for creating Lamdera apps
which has a number of useful built-in features. The notes
below provide some information on how they work and how
to use them.

*I intend to improve and add to the notes as time permits.  If you have
questions or suggestions, please let me know: jxxcarlson everywhere.*

**Contents**

- Admin page
- Routing: Adding a new page
- Ports: sending a message to JavaScript
- Custom Elements
- Outbound HTTP requests
- RPC example
- Stripe: Account and API
- Stripe: Displaying Product Information to the User
- Stripe: Submitting a Purchase


## Admin page

There is now a rudimentary Admin page.  At the moment        ,
it can do two things:

- Display user data
- Display data on the stripe interface.

Use the buttons at the top of the Admin page to select
the view you want.

Here is a sample of the user data that is displayed
for users.

```
User Data

realname: Aristotle
username: aristotle
email: aristotle@philosophy.gr
id: 38952d62-9772-4e5d-a927-b8e41b6ef2ed

realname: Jim
username: jxxcarlson
email: jxxcarlson@gmail.com
id: 661b76d8-eee8-42fb-a28d-cf8ada73f869
```

## Routing: Adding a new page

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






## Ports

The code for setting up communication between Elm and JavaScript
is found in three places:

 - The directory `elm-pkg-js` with files. Javascript files in this directory
 define functions that communicate with Elm.

 - The module `Ports`. It houses counterparts of the functions in `elm-pkg-js`.

 - The file `elm-pkg-js-includes.js`. It informs Lamdera of the existence of
 of the files in `elm-pkg-js` and makes them available in production.


**Example.**

Consider the function



 ```
 module Ports exposing (..)

 port playSound : Json.Encode.Value -> Cmd msg
 ```

It is paired with the function `app.ports.playSound` in
 `elm-pkg-js/play-sound.js`.

The **Chirp** button you see on the home page sends a message
`Chirp` which is handled in `Frontend.update`:

```elm
Chirp -> ( model, Ports.playSound (Json.Encode.string "chirp.mp3") )
```

The command `Ports.playSound (Json.Encode.string "chirp.mp3")` communicates
with its Javascript counterpart in  `elm-pkg-js/play-sound.js`:

```javascript
exports.init = async function init(app) {

    app.ports.playSound.subscribe( function(filename) {
        console.log("Playing sound", filename)
        var audio = new Audio(filename);
        audio.play();
    })
}
```

The result is that a "chirp" sound is played when the button is clicked.





## Custom Elements

Let's talk about the custom element `time-formatted` which you will find
on the home (Kitchen sink) page. The code for this element is in
`elm-pkg-js/time-formatted.js`.  It is paired with the Elm function

```
timeFormatted : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
timeFormatted =
    Html.node "time-formatted"
```

The `timeFormatted` function is called in `Pages.Home` via the code

```
Element.el [ Element.paddingXY 0 0 ]
    (View.CustomElement.timeFormatted
        [ Html.Attributes.attribute "id" "elem"
        , Html.Attributes.attribute "hour" "numeric"
        , Html.Attributes.attribute "minute" "numeric"
        , Html.Attributes.attribute "second" "numeric"
        , Html.Attributes.attribute "time-zone-name" "short"
        ]
        []
        |> Element.html
    )
```

Note that `time-formatted.js` is also referenced in
`elm-pkg-js-includes.js` so that it will be available in production.

[Documentation](https://javascript.info/custom-elements#example-time-formatted)

**References**

- [Elm Guide on Custom Elements](https://guide.elm-lang.org/interop/custom_elements.html)

- [MDN Docs](https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements)

- [reCAPTCHA](https://bigardone.dev/blog/2018/09/09/elm-and-web-components)

- [Korban, a Straightforward Guide to Custom Elements](https://korban.net/posts/elm/2018-09-17-introduction-custom-elements-shadow-dom/)

- [Luke Westby's talk on Custom Elements](https://www.youtube.com/watch?v=tyFe9Pw6TVE)

## Outbound HTTP requests

Recall that on the Home (Kitchen Sink) page there is an input field
for names of cities.  If you type in a city name and hit `<return>`,
the temperature in the named city is displayed.  This is done by
issuing an an HTTP request to the [OpenWeatherMap API](https://openweathermap.org/).
Supporting code for this request resides in the module `Weather`.

The reason for issuing the request from the backend is that the
API key is sensitive information.  If the request were issued
from the frontend, the key would be visible to anyone
running the app frontend.

Here is the flow of information:

1. The user types in a city name and hits `<return>`.  This
   sends a message `RequestWeatherData model.inputCity` to the frontend update function.

2. The frontend update function executes the command
 `Lamdera.sendToBackend (GetWeatherData city)` at `RequestWeatherData`.

3. The backend update function handles the message `GetWeatherData city`
   by executing the command `BackendHelper.getNewWeatherByCity clientId city`.

4. The function `Weather.getWeatherData` issues an HTTP request to `https://api.openweathermap.org`
   with

   `
   expect = Http.expectJson (Types.GotWeatherData clientId) Weather.weatherDataDecoder
   `
5. The response is decoded by `Weather.weatherDataDecoder` at
   `GotWeatherData clientId (Ok weatherData)` in the backend update function.
   The command `Lamdera.sendToFrontend clientId (Types.ReceivedWeatherData result) )`
   is executed.

6. The frontend update function handles the message `ReceivedWeatherData result`. If
the result is a successful one, we have in hand the weather data for the city.
It is stored in the `weatherData` field of the frontend model. The view function
extracts the city temperature from the weather data and displays it.

## RPC example

*Offer a service where key-value pairs can be stored and retrieved.*

The backend model has a field `keyValueStore : Dict String String`.  The
contents of the store are displayed in the Admin page.  New
key-value pairs can be inserted via an RPC call to endpoint `putKeyValuePair`.
See function `RPC.putKeyValuePair`.  To retrieve a value, use the
endpoint `getKeyValuePair`.

Here is an example of how the
pair `Speed of light: 300,000 km/sec` was added the store:

```
   curl -X POST -d '{ "key": "Speed of light", "value": "300,000 km/sec" }' \\
   -H 'content-type: application/json' localhost:8000/_r/putKeyValuePair
```

And here is how it is retrieved:

```
 curl -X POST -d '{ "key": "Speed of light" }' \\
 -H 'content-type: application/json' localhost:8000/_r/getKeyValuePair
 ```

This could be a useful feature in production if the security
issues it poses are addressed.


## Stripe: Account and API

*((This section and the supporting code in the template is a work in progress.
I will remove this paragraph when the work is done.  In the meantime, if you have
suggestions, comments, or suggestions, let me know: jxxcarlson everywhere: slack, discourse, gmail))*

To use Stripe you will need to set up a Stripe account, get a Stripe API key,
and set up products and prices. Go to [stripe.com](https://stripe.com) to set up your account,
and use [dashboard.stripe.com/apikeys](https://dashboard.stripe.com/apikeys) to
create an view your API keys. To create products and prices, it is best to use
the [Stripe Dashboard](https://dashboard.stripe.com/) and in particular
the [Product Dashboard](https://dashboard.stripe.com/products).

Your app will interact with Stripe using Http requests.  See, for example
the section **Getting lists of products and prices using the Stripe API** below.
You will need this data to create a checkout page in your app.

You can also use the Stripe CLI to create and view products and prices.


**Articles**

- [Stripe API Reference](https://stripe.com/docs/api)

- [How to create products and prices with the dashboard](https://support.stripe.com/questions/how-to-create-products-and-prices)


**Links**

- [Stripe Dashboard](https://dashboard.stripe.com/)

- [Product Dashboard](https://dashboard.stripe.com/products)

**Getting your product and price lists using the Stripe API**

For a list of products, make a GET request with URL `https://api.stripe.com/v1/products`
and header `Authorization` with value `Bearer <your secret key>`.  The
test secret key looks like: `sk_test_...`  You find your keys at
[dashboard.stripe.com/apikeys](https://dashboard.stripe.com/apikeys).
Your data will be returned in JSON format.

Note the button to switch between live and test mode.  Live mode
 is for real transactions Because
the secret key is sensitive information, any request using it MUST be
made from the backend.

For a list of prices, make a GET request with URL `https://api.stripe.com/v1/prices`.


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



## Stripe: Displaying Product Information to the User

When the app is initialized, it makes a GET request to the Stripe API to get
a list of products and prices.  This is done via the function call
`tripe.getPrices GotPrices` in the backend model. This data is stored in the
the `prices : AssocList.Dict (Id ProductId) Price2` field of the model.
This is a dictionary whose keys are product ids and whose values are
`Price2` records

In addition to the product and price data returned by the Stripe API,
there is a field `products : Stripe.Stripe.ProductInfoDict`
which maps product ids to `Stripe.Stripe.ProductInfo` records.  These
have a name and a description field.  The products dictionary
is (at the moment) hard-coded in the backend model.

At init time, both dictionaries sent to the frontend model and stored there.
This information can be displayed to the user in the checkout page.

Here is an example of what is returned:


**Price and product info from Stripe**

```
prod_NwykP5NQq7KEJt  price_1NBJdgJtjekdqXYjglFb61DA  600
prod_Nwym3t9YYdA0DD  price_1NBK0YJtjekdqXYjJfqCoryx  900
```

**Price and product view for user**

```
Basic Package    100 image credits     $6
Jumbo Package    200 image credits     $9
```



## Stripe: Submitting a Purchase

The code & UI is now in place to make purchases using Stripe.
I've run the deployed app and made a purchase using the test API keys.
As the log below shows, the purchase was successful.

To get a log like this use the Stripe CLI:

```
$ stripe login
$ stripe logs tail
```

```
2023-12-31 21:19:06 [200] POST /v1/checkout/sessions/:id/expire [req_AZUOd0YTu2CjZ2]
2023-12-31 21:20:34 [200] POST /v1/payment_methods [req_2p6JzfZEPJAG1J]
2023-12-31 21:20:35 [200] POST /v1/payment_pages/:id/confirm [req_BNEucq56JENSQf]
2023-12-31 21:20:38 [200] GET /v1/checkout/sessions/completed_webhook_delivered/:id [req_n3R7HHrcJOWfHr]
2023-12-31 21:20:38 [200] GET /v1/checkout/sessions/completed_webhook_delivered/:id [req_7lRYJcxaUBQkjc]
```

NEXT: Documenting the code.




"""
        |> MarkdownThemed.renderFull

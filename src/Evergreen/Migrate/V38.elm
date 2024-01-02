module Evergreen.Migrate.V38 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.app/docs/evergreen> for more info.

-}

import AssocList
import Evergreen.V33.Email
import Evergreen.V33.EmailAddress
import Evergreen.V33.Id
import Evergreen.V33.Name
import Evergreen.V33.Route
import Evergreen.V33.Stripe.Codec
import Evergreen.V33.Stripe.PurchaseForm
import Evergreen.V33.Stripe.Stripe
import Evergreen.V33.Stripe.Tickets
import Evergreen.V33.Types
import Evergreen.V38.Email
import Evergreen.V38.EmailAddress
import Evergreen.V38.Id
import Evergreen.V38.Name
import Evergreen.V38.Route
import Evergreen.V38.Stripe.Codec
import Evergreen.V38.Stripe.Product
import Evergreen.V38.Stripe.PurchaseForm
import Evergreen.V38.Stripe.Stripe
import Evergreen.V38.Types
import Lamdera.Migrations exposing (..)
import Maybe


frontendModel : Evergreen.V33.Types.FrontendModel -> ModelMigration Evergreen.V38.Types.FrontendModel Evergreen.V38.Types.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Evergreen.V33.Types.BackendModel -> ModelMigration Evergreen.V38.Types.BackendModel Evergreen.V38.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V33.Types.FrontendMsg -> MsgMigration Evergreen.V38.Types.FrontendMsg Evergreen.V38.Types.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Evergreen.V33.Types.ToBackend -> MsgMigration Evergreen.V38.Types.ToBackend Evergreen.V38.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V33.Types.BackendMsg -> MsgMigration Evergreen.V38.Types.BackendMsg Evergreen.V38.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V33.Types.ToFrontend -> MsgMigration Evergreen.V38.Types.ToFrontend Evergreen.V38.Types.FrontendMsg
toFrontend old =
    MsgUnchanged
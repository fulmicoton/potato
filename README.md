Potato : A composition-friendly Microframework
=================================================

Potato is a CoffeeScript micro-framework focused
on composition. It relies on its own object model, whose syntax might recall that of an ORM.


Object composition
-------------------------------------------------

To declare a model for a user profile, you would typically declare it as a composition of the information of name, age and address. Address itself will be the composition of a street/city/zipcode/state/country.


```CoffeeScript

    O = require 'potato'

    Address = O.Potato
        components:
            street:  O.String
            city:    O.String
            zipcode: O.String
    
    Profile = O.Potato
        components:
            name:    O.String
            address: Address
            age:     O.Int
```

You may notice that this syntax also allows to inline the definition of a very simple composed object that is very unlikely to be reused. For instance :

    :::coffeescript
    O = require 'potato'

    UserInformation = O.Potato
        components:
            name: O.Potato
                components:
                    first_name: O.String
                    last_name:  O.String
            age: O.Int
            address: Address

Though this style is not really recommended for such a definition, this syntax comes very handful with the
deep-overriding feature described below.

    :::coffeescript
    O = require 'potato'.

    UserInformation = O.Potato
        components:
            name: O.Potato
                components:
                    first_name: O.String
                    last_name:  O.String
            age:  O.Int
            address: Address



Inheritance, and deep-overriding.
--------------------------------------------------
 
 The children components of your potatoes may themselves have components and your potatoes might rapidly look like small tree-like structures of components. You might still want to extend it, and override a piece of functionality located slightly deeper than in the very first layer of this tree.

Potato makes it possible for you to inherit from an object, and extend or override pretty much anything, wherever in this tree ; be that a component, a method, or a static property of a component.

For instance, my address potato was assuming that my users were french. For international users I'll need
to at least add a state and a country mention.

    :::coffeescript       
    # ...
    # here we added two new components
    # to our Address object.

    InternationalAddress = Address
        components:
            state:   O.String
            country: O.String

String (as well as all Literal types) has a static property called default that describes the default value
that should be produced on instantiation.

Let's say we actually wanted to have "USA", "NY", "New York City" as the default values for the country and the state components. We could have written :

    :::coffeescript
    # ...
    InternationalAddress = Address
        components:
            city:    O.String
                default: "New York City"
            state:   O.String
                default: "NY"
            country: O.String
                default: "USA"



Static properties, methods, literals
--------------------------------------------------

Your object may have static members. These are pretty like static members in C++ or python etc. They are accessible from the Potato itself, but not from its instances.

The most obvious one is "make" which makes it possible to instantiate a potato.

    :::coffeescript
    #
    # This should make an address with : 
    # all our default values.
    #
    address = InternationalAddress.make()


You may define more static members using the 
"static" section prefix. For instance, Potato's Models have a JSON deserialization function which looks pretty much like this. 
    
    :::coffeescript
    Model = O.Potato
        static:
            fromJSON: (json)->
                @make JSON.parse json

On the other hands methods are made to be called from 
objects.
A model also have a toJSON method, which looks like :

    :::coffeescript
    Model = O.Potato
        methods:
            toJSON: ->
                JSON.stringify @toData()

As an helper, a static function is actually also magically created, taking the object to which it should be bound to as a first argument.

Someone in fond of functional programming may write things such as 
    
    :::coffeescript
    map Model.toJSON, someListOfModels

as an alternative to
    
    :::coffeescript
    model.toJSON() for model in someListOfModels




Knowing your components is a cool thing.
--------------------------------------------------

Your objects are aware of their components and their types and that is a great things.

Validation
Serialization
Generic forms
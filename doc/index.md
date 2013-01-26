
Getting started
=================================================
[![Build Status](https://secure.travis-ci.org/poulejapon/potato.png)](http://travis-ci.org/#!/poulejapon/potato)


NodeJS
------------------

```bash
    npm install potato
```


In the browser
-------------------

[Download the Latest Version **0.1.1**   [ Tar Ball ] ](https://github.com/poulejapon/potato/archive/0.1.1.tar.gz)

Potato comes in two flavour. 

**potato.min.js** in which the potato module will endup as "potato" in your global
namespace. 

**potato-browserify.min.js** which is browserified. In that case, the potato module is returned by the call `require potato`. 
In the following examples we will consider the latter, and assign via `O = require 'potato'`.



Core
=================================================



Potato is a CoffeeScript micro-framework focused
on composition. It relies on its own object model, whose syntax
might recall that of an ORM.

Object composition
-------------------------------------------------

To declare a model for a user profile, you would typically declare it as a composition of the information of name, age and address. Address itself will be the composition of a street/city/zipcode/state/country.

```coffeescript
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



```coffeescript
O = require 'potato'

UserInformation = O.Potato
    components:
        name: O.Potato
            components:
                first_name: O.String
                last_name:  O.String
        age: O.Int
        address: Address
```



Though this style is not really recommended for such a definition, this syntax comes very handful with the
deep-overriding feature described below.

```coffeescript
O = require 'potato'

UserInformation = O.Potato
    components:
        name: O.Potato
            components:
                first_name: O.String
                last_name:  O.String
        age:  O.Int
        address: Address
```


Deep Inheritance
--------------------------------------------------
 
 The children components of your potatoes may themselves have components and your potatoes might rapidly look like small tree-like structures of components. You might still want to extend it, and override a piece of functionality located slightly deeper than in the very first layer of this tree.

Potato makes it possible for you to inherit from an object, and extend or override pretty much anything, wherever in this tree ; be that a component, a method, or a static property of a component.

For instance, my address potato was assuming that my users were french. For international users I'll need
to at least add a state and a country mention.

```coffeescript
# ...
# here we added two new components
# to our Address object.

Address = potato.Potato
    components:
        state:   O.String
        country: O.String
```


String (as well as all Literal types) has a static property called default that describes the default value
that should be produced on instantiation.

Let's say that our new application will have to handle american addresses. We'd like to use the work done with our Address model, **override** a couple of values and **add a state field**.

We could have written :

```coffeescript
# ...
AmericanAddress = Address
    components:
        city:    O.String
            default: "New York City"
        state:   O.String
            default: "NY"
        country: O.String
            default: "USA"
```



Static properties, methods, literals
--------------------------------------------------

Your object may have static members. These are pretty like static members in C++ or python etc. They are accessible from the Potato itself, but not from its instances.

The most obvious one is "make" which makes it possible to instantiate a potato.

```coffeescript
#
# This should make an address with : 
# all our default values.
#
address = InternationalAddress.make()
```


You may define more static members using the 
"static" section prefix.

```coffeescript

O = require 'potato'
# ...
Color = O.Potato
    components:
        r: O.Integer
        g: O.Integer
        b: O.Integer
    static:
        fromHexCode: (hexCode)->
            # ...

trendyPink = Color.fromHexCode '#ff9900'
```

In addition, in a pythonic fashion, all your methods are available as static methods.

```coffeescript
O = require 'potato'
# ...
Color = O.Potato
    components:
        r: O.Integer
        g: O.Integer
        b: O.Integer
    methods:
        toHexCode: ->
            # ...
    static:
        fromHexCode: (hexCode)->
            # ...

trendyPink = Color.fromHexCode '#ff9900'
console.log trendyPink.toHexCode() 
# should log '#ff9900'
# and is equivalent to ...
console.log Color.toHexCode trendyPink
```

Potato also allows to attach static methods
to javascript literals. You might want to 
describe a type for which instances are simple
strings and add a validation method.

```coffeescript
O = require 'potato'
Email = O.String
    EMAIL_PTN:  /// ^    #begin of line
       ([\w.-]+)         #one or more letters, numbers, _ . or -
       @                 #followed by an @ sign
       ([\w.-]+)         #then one or more letters, numbers, _ . or -
       \.                #followed by a period
       ([a-zA-Z.]{2,6})  #followed by 2 to 6 letters or periods
       $ ///i   
    validate: (val)->
        if @EMAIL_PTN.exec(val)?
            ok: true
        else
            ok: false
            errors: 'This is not a valid email address.'
```


Type Introspection
--------------------------------------------------

When writing objects inheriting from Potato, members listed
in the **components** section are accessible via the
**components** method, available for both the potato and
its instances.

You may hide some properties from the @components method by 
declaring them in the **property** section.

It is helpful to implement **transient properties**, that should
not be serialized for instance.

```coffeescript
O = require 'potato'

Box = O.Potato
    property:
        _surface: O.Integer
            default: undefined
    components:
        x: O.Integer
        y: O.Integer
        w: O.Integer
        h: O.Integer
    methods:
        surface: ->
            if not @surface?
                @surface = @w*@h
            @surface

for k,v of Box.components()
    # k takes  ("x", "y", "w", h) for value in this loop
    # v takes potato.Integer for value in this loop.
    console.log k 

box = Box.make()
for k,v of box.components()
    # it works just the same with instances.
    console.log k 

```
For instance, this functionality makes it possible a lot of the functionalities of potato
(toJSON, validation, automatic form generation).




Events
=================================================



EventCasters
----------------------------------------------

Event casters follows the same syntax as jQuery 
event-binding. Everything is done using **unbind/bind/trigger methods**.

```coffeescript
    O = require 'potato'

    Engine = O.EventCaster
        methods:
            start: ->
                if not @intervalId?
                    console.log "start!"
                    @intervalId = setInterval (=> @trigger 'run'), 500
            stop: ->
                console.log "stop!"
                clearInterval @intervalId
                @intervalId = null

    Wheel = O.EventCaster
        components:
            name: O.String
        methods:
            roll: -> console.log "#{@name} rolling!"
        static:
            named: (name)-> @make {name: name}

    MotorBike = O.Potato
        components:
            engine: Engine
            frontWheel: Wheel
                components:
                    name: O.String
                        default: "Front Wheel"
            backWheel: Wheel
                components:
                    name: O.String
                        default: "Back Wheel"
        methods:
            clutch: ->
                for wheel in [@frontWheel, @backWheel]
                    do (wheel)=>
                        @engine.bind 'run', -> wheel.roll()
            declutch: ->
                engine.unbind 'run', -> wheel.roll()

    motorbike = MotorBike.make()
    motorbike.clutch()
    motorbike.engine.start()

```


Model
=================================================



View
=================================================

Form generation
=================================================
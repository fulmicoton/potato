potato = require '../'

window = require('jsdom').jsdom('<html><head></head><body></body></html>').createWindow()
$ = require "jquery"


describe 'potato.Literal', ->
    
    it 'allows instantiation', ->
        TestLiteral = potato.Literal
            default: 5
        expect(TestLiteral.make()).toEqual(5)
        
    it 'link to default values rather than give reference to them', ->
        TestList = potato.Literal
            default: [2]
        l = TestList.make()
        expect(l.length).toEqual(1)
        l.push 1
        expect(l.length).toEqual(2)
        l = TestList.make()
        expect(l.length).toEqual(2)
    
    it 'allows functions as default function', ->
        TestList = potato.Literal
            default: ->[2]
        l = TestList.make()
        expect(l.length).toEqual(1)
        l.push 1
        l = TestList.make()
        expect(l.length).toEqual(1)

    it 'allows to have typed list', ->
        TestList = potato.ListOf potato.Integer
        expect(TestList.make([0])[0]).toEqual(0)

describe 'potato.String', ->
       
    it 'returns empty string by default', ->
        expect(potato.String.make()).toEqual ''

    it 'has allows validation', ->
        expect(potato.String.validate 4).toEqual
            ok: false
            errors: 'Expected a string.'

    it 'has allows validation', ->
        expect(potato.String.validate '').toEqual
            ok: true

    it 'has allows validation', ->
        expect(potato.NonEmptyString.validate '').toEqual
            ok: false
            errors: 'Must not be empty.'

describe 'potato.EventCaster', ->
    
    it 'cast events', ->
        eventCaster = potato.EventCaster.make()
        someValue = 0
        eventCaster.bind 'someEvent', (val)->
            someValue = val
        eventCaster.trigger 'someEvent', 100
        expect(someValue).toEqual 100
           
    it 'differentiates caster', ->
        eventCaster = potato.EventCaster.make()
        eventCaster2 = potato.EventCaster.make()
        someValue = 0
        eventCaster.bind 'someEvent', (val)->
            someValue = val
        eventCaster2.trigger 'someEvent', 100
        expect(someValue).toEqual 0
    
    it 'allows unbinding.', ->
        eventCaster = potato.EventCaster.make()
        count = 0
        callback = ->
            count += 1
        eventCaster.bind "test", callback
        expect(count).toEqual(0)
        eventCaster.trigger "test"
        expect(count).toEqual(1)
        eventCaster.unbind "test", callback
        eventCaster.trigger "test"
        expect(count).toEqual(1)
        
     it 'runs all callback on a trigger,
         independantly from the binding/unbinding that 
         may happen in the firsts callback.', ->
        # that's a tricky one!
        eventCaster = potato.EventCaster.make()
        count = 0
        callback2 = ->
            count += 1
        callback1 = ->
            eventCaster.unbind "test", callback2
        eventCaster.bind "test", callback1
        eventCaster.bind "test", callback2
        eventCaster.trigger "test"
        expect(count).toEqual(1)
        eventCaster.trigger "test"
        expect(count).toEqual(1)


describe 'potato.Model', ->
    
    it 'helps describe Model', ->
        SomeSubModel = potato.Model
            components:
                a: potato.String
                    default: "Some a"
                b: potato.String
        SomeModel = potato.Model
            components:
                name: potato.String
                    default: "Some Name"
                title: potato.String
                    default: "Some Title"
                submodel: SomeSubModel
        model = SomeModel.make()
        expect(model.name).toEqual "Some Name"
        expect(model.title).toEqual "Some Title"
        expect(model.submodel.a).toEqual "Some a"
        expect(model.submodel.b).toEqual ""
    
    it 'accepts value for testing', ->
        SomeSubModel = potato.Model
            components:
                a: potato.String
                    default: "Some a"
                b: potato.String
        SomeModel = potato.Model
            components:
                name: potato.String
                    default: "Some Name"
                title: potato.String
                    default: "Some Title"
                submodel: SomeSubModel
        model = SomeModel.make
            title: "Some Other Name"
            submodel:
                b: "Some Custom b"
        expect(model.name).toEqual "Some Name"
        expect(model.submodel.a).toEqual "Some a"
        expect(model.submodel.b).toEqual "Some Custom b"

    it 'has toData/setData', ->
        Profile = potato.Model
            components:
                nickname: potato.String
                first_name: potato.String
                last_name: potato.String
                age: potato.Integer
        profile = Profile.make()
        profile.setData
            nickname: 'Patoulette'
            age: 12
        expect(profile.toData()).toEqual
            nickname: 'Patoulette'
            age: 12
            first_name: ''
            last_name: ''
    
    it 'offers components method to list subcomponents', ->
        SomeModel = potato.Model
            components:
                a: potato.String
                b: potato.String
            properties:
                c: potato.String
        expect(SomeModel.components().a).toBeDefined()
        expect(SomeModel.components().b).toBeDefined()
        expect(SomeModel.components().c).toBeUndefined()
        model = SomeModel.make()
        expect(model.components().a).toBeDefined()
        expect(model.components().b).toBeDefined()
        expect(model.components().c).toBeUndefined()
        expect(model.c).toBeDefined()
    
    it 'offers components method to list subcomponents', ->
        SomeModel = potato.Model
            components:
                a: potato.String
                b: potato.String
            properties:
                c: potato.String
        model = SomeModel.make()

    it 'offers properties', ->
        SomeModel = potato.Model
            properties:
                count: potato.Integer
        model = SomeModel.make()
        expect(model.count).toEqual(0)
        SomeOtherModel = potato.Model
            properties:
                count: potato.Integer
                    default: 1
        model2 = SomeOtherModel.make()
        expect(model2.count).toEqual(1)

    it 'offers validation and components validation', ->
        SmartDressCode = potato.Model
            components:
                shoes: potato.String
                    validate: (data)->
                        if data == "sneakers"
                            ok: false
                            errors: "No Sneakers please"
                        else
                            ok: true
                top: potato.String
                    validate: (data)->
                        if data == "T-Shirt"
                            ok: false
                            errors: "T-Shirt are not accepted."
                        else
                            ok: true
        steveJobsValidation = SmartDressCode.validate
            shoes: "sneakers"
            top: "turtle neck"
        expect(steveJobsValidation).toEqual
            ok: false
            errors:
                shoes: "No Sneakers please"
        linusValidation = SmartDressCode.validate
            shoes: "sneakers"
            top: "T-Shirt" 
        expect(linusValidation).toEqual
            ok: false
            errors:
                shoes: "No Sneakers please"
                top: "T-Shirt are not accepted."
        jamesBondValidation = SmartDressCode.validate
            shoes: "Souliers"
            top: "Costume"
        expect(jamesBondValidation).toEqual
            ok: true
        

describe 'potato.CollectionOf', ->
    
    it 'can be made', ->
        A = potato.CollectionOf(potato.String)
        a = A.make()
        expect(a.toData()).toEqual([])

    it 'we can add data', ->
        A = potato.CollectionOf(potato.String)
        a = A.make()
        a.addData "coucou"
        expect(a.toData()).toEqual(["coucou"])

    it 'we can set data', ->
        A = potato.CollectionOf(potato.String)
        a = A.make()
        a.setData ["a", "b"]
        expect(a.toData()).toEqual ["a", "b"]

    it 'we can set data', ->
        A = potato.CollectionOf(potato.String)
        a = A.make()
        a.setData ["a", "b"]
        expect(a.toJSON()).toEqual JSON.stringify a.toData()


describe 'potato.View', ->
                
    it 'offers properties', ->
        SomeView = potato.View
            properties:
                count: potato.Integer
        view = SomeView.make()
        expect(view.count).toEqual(0)
        SomeOtherView = potato.View
            properties:
                count: potato.Integer
                    default: 1
        view2 = SomeOtherView.make()
        expect(view2.count).toEqual(1)

    it 'offers events binding ', ->
        SomeView = potato.View
        view = SomeView.make()
        expect(view.__bound__).toEqual([])

describe 'potato.extend', ->

    it 'works like a 1-level deepcopy when used with {}', ->
        c = {k: 2, obj: {a: 3}}
        cClone = potato.extend {}, c
        expect(cClone.k).toEqual(2)
        expect(cClone.obj.a).toEqual(3)
        c.k = 3
        c.obj.a = 4
        expect(cClone.k).toEqual(2)
        expect(cClone.obj.a).toEqual(4)
    
    it 'makes it possible to merge dictionaries', ->
        c1 = {k1: 1}
        c2 = {k2: 2}
        c3 = {k3: 3}
        c4 = potato.extend c1, c2, c3
        expect(c4).toEqual(c1)
        expect(c1.k1).toEqual 1
        expect(c1.k2).toEqual 2
        expect(c1.k3).toEqual 3

    it 'only works on the first level', ->
        c1 = {k: {a: 1}}
        c2 = {k: {b: 2}}
        potato.extend c1, c2
        expect(c1.k.a).toBeUndefined()
        expect(c1.k.b).toEqual 2

describe 'potato.rextend', ->
    
    it 'works like a (infinite-level) deepcopy when used with {}', ->
        c = {k: 2, obj: {a: 3}}
        cClone = potato.rextend {}, c
        expect(cClone.k).toEqual(2)
        expect(cClone.obj.a).toEqual(3)
        c.k = 3
        c.obj.a = 4
        expect(cClone.k).toEqual(2)
        expect(cClone.obj.a).toEqual(3)

    it 'works does not recursively call itself for object that are not simple dictionary', ->
        class A
            constructor: (@val)->
            half: ->
                @val/2
        a = new A(14)
        clone = potato.rextend {}, {obj:a}
        expect(clone.obj.half()).toEqual(7)
    

    it 'makes it possible to merge dictionaries', ->
        c1 = {k1: 1}
        c2 = {k2: 2}
        c3 = {k3: 3}
        c4 = potato.rextend c1, c2, c3
        expect(c4).toEqual(c1)
        expect(c1.k1).toEqual 1
        expect(c1.k2).toEqual 2
        expect(c1.k3).toEqual 3

    it 'works on deep levels', ->
        c1 = {k: {a: 1}}
        c2 = {k: {b: 2}}
        potato.rextend c1, c2
        expect(c1.k.a).toEqual 1
        expect(c1.k.b).toEqual 2


describe 'potato.removeEl', ->

    it 'deletes the first occurence of an el in an array by default', ->
        arr = [10,11,12,10,11,12]
        nbRemovedEl = potato.removeEl arr, 11
        expect(nbRemovedEl).toEqual(1)
        expect(arr).toEqual([10,12,10,11,12])
    
    it 'returns the number of deleted elements', ->
        arr = [10,11,12]
        nbRemovedEl = potato.removeEl arr, 11, 2
        expect(nbRemovedEl).toEqual(1)
    
    it 'deletes n-occurrences when given n as an extra argument', ->
        arr = [10,11,11,11,12]
        nbRemovedEl = potato.removeEl arr, 11, 2
        expect(nbRemovedEl).toEqual(2)
        expect(arr).toEqual([10,11,12])
    
    it 'makes it possible to delete all the occurence of an el in an array when given -1', ->
        arr = [10,11,11,11,12]
        nbRemovedEl = potato.removeEl arr, 11, -1
        expect(nbRemovedEl).toEqual(3)
        expect(arr).toEqual([10,12])


describe 'potato.split', ->

    it 'returns [string] if the splitter is not here', ->
        chunks = potato.split "abcdef", "g"
        expect(chunks).toEqual(["abcdef"])
        chunks = potato.split "abcdef", /g/
        expect(chunks).toEqual(["abcdef"])

    it 'splits the string if the splitter is in the string', ->
        chunks = potato.split "abc9ef", "9"
        expect(chunks).toEqual(["abc", "ef"])
        chunks = potato.split "abc9ef", /\d/
        expect(chunks).toEqual(["abc", "ef"])

    it 'returns a single empty string as the last item if the string ends by the splitter', ->
        chunks = potato.split "abc9ef9", "9"
        expect(chunks).toEqual(["abc", "ef", ""])
        chunks = potato.split "abc9ef9", /\d/
        expect(chunks).toEqual(["abc", "ef", ""])    

    it 'works with splitter with more than one letter', ->
        chunks = potato.split "abc99ef99gh", "99"
        expect(chunks).toEqual(["abc", "ef", "gh"])
        chunks = potato.split "abc99ef99gh", /\d+/
        expect(chunks).toEqual(["abc", "ef", "gh"])

    it 'allows to add a number of max split', ->
        chunks = potato.split "abcddefddgh", "dd", 2
        expect(chunks).toEqual(["abc", "efddgh"])
        chunks = potato.split "abcddefddgh", "dd", 1
        expect(chunks).toEqual(["abcddefddgh"])
        chunks = potato.split "abcddefddgh", /d+/, 2
        expect(chunks).toEqual(["abc", "efddgh"])



describe 'potato.Email', ->
    
    it 'has validation', ->
        expect(potato.Email.validate "paul.masurel@gmail.com").toEqual
            ok: true
        expect(potato.Email.validate "paul.masurelgmailcom").toEqual
            ok: false
            errors: 'This is not a valid email address.'

describe 'potato.View', ->

    it 'can be loaded into a DOM element', ->
        $body = $ "body"
        expect($body.length).toEqual 1
        TestView = potato.View
            template: "hello {{ name }}"
            methods:
                context: (parent)->name: "toto"
        TestView.loadInto $ "body"
        expect($body.html()).toEqual "hello toto"

    it 'can receive a context from its parent', ->

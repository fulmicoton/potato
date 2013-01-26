model = require './model'


NonEmptyString = model.String
    default: "something..."
    validate: (data)->
        validAsString = model.String.validate data
        if validAsString.ok and data != ""
            { ok: true }
        else
            { ok: false, errors: "Must not be empty." }



Email = model.String
    EMAIL_PTN:  /// ^ #begin of line
       ([\w.-]+)         #one or more letters, numbers, _ . or -
       @                 #followed by an @ sign
       ([\w.-]+)         #then one or more letters, numbers, _ . or -
       \.                #followed by a period
       ([a-zA-Z.]{2,6})  #followed by 2 to 6 letters or periods
       $ ///i   
    validate: (val)->
        if @EMAIL_PTN.exec(val)?
            ok:true
        else
            ok:false
            errors: 'This is not a valid email address.'

module.exports =
    Email: Email
    NonEmptyString: NonEmptyString
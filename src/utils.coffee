
# Potatoe offers a new way to define objects
# in CoffeeScript.
# It is especially suited for objects that rely
# heavily on composition (e.g. : Models).
#
extend = (dest,extras...) ->
    for extra in extras
        for k,v of extra
            dest[k] = v
    dest


stringSplitOnce = (splitter)->(s)->
    pos = s.indexOf splitter
    if pos >= 0
        [ s[...pos], s[pos+splitter.length...] ]
    else
        undefined

regexSplitOnce = (splitter)->(s)->
    match = splitter.exec(s)
    if match?
        matchLength = match[0].length
        pos = match.index
        [ s[...pos], s[pos+matchLength...] ]
    else
        undefined

SPLIT_ONCE_PER_TYPE = 
    "string": stringSplitOnce
    "object": regexSplitOnce

genericSplitOnce = (splitter)->
    typeSpecificSplitOnce = SPLIT_ONCE_PER_TYPE[typeof splitter]
    typeSpecificSplitOnce splitter

split = (s, splitter, n=-1)->
    ###
    Split the string at the positions of the splitter.
    The splitter may be either a regexp or a string.
    
    If a parameter n>0 is given, the string is split only
    at the position of the first n-1 occurrences,
    therefore  resulting in a list of n substrings.
    ###
    splitOnce = genericSplitOnce splitter
    chunks = []
    while n!=1
        splitResult = splitOnce s
        if splitResult?
            [h,t] = splitResult
            s = t
            chunks.push h
            n -= 1
        else
            break
    chunks.push s
    return chunks

removeEl = (arr, el, n=1)->
    ###
      Remove the n first occurrences of 
    el in array arr.
      Removes all the occurences if given -1.
      Returns the number of suppressed
    elements
    ###
    nbOcc = n
    while (nbOcc != 0)
        elId = arr.indexOf el
        if elId != -1
            arr.splice(elId, 1)
            nbOcc -= 1
        else
            return n-nbOcc
    n

twoRecursiveExtend = (dest, extra)->
    for k,v of extra
        if (typeof v) == "object" and v? and not v.length?
            # v is a non-null object and is not an array.
            if not dest[k]?
                dest[k] = {}
            rextend dest[k], v
        else
            dest[k]=v
    dest

rextend = (objs...)->
    res = objs[0]
    for obj in objs[1..]
        twoRecursiveExtend res,obj
    res


# If callable, return the result of its call,
# return the value if it is not callable.
pick = (v)->
    if typeof v == "function"
        v()
    else
        v

mapDict = (f, c)->
    res = {}
    for k,v of c
        res[k] = f(v)
    res

log = (msg)->
    console?.log msg

module.exports = 
    extend: extend
    mapDict: mapDict
    pick: pick
    split: split
    rextend: rextend
    removeEl: removeEl
    log: log
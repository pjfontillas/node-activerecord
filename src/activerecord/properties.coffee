{Inflection} = require './support/inflection'

module.exports = 
  createProperties: ->
    for field in [@primaryKey].concat(@fields) then do (field) =>
      @data[field] = if @initData[field] then @initData[field] else null
      Object.defineProperty @, field,
        enumerable: true
        configurable: false
        get: -> @readAttribute(field)
        set: (val) ->
          # We don't allow the primary index to be set via
          # accessor method.
          return if field is @primaryKey
          if @readAttribute(field) isnt val
            val = @applyAttributeFilter(field, val)
            @writeAttribute(field, val)
            @dirtyKeys[field] = true
            @isDirty = true

  applyAttributeFilter: (field, val) ->
    return val unless @observer?
    
    filterFunc = "filter#{Inflection.camelize(field)}"
    return val unless @observer::[filterFunc]?

    @observer::[filterFunc].call(@, val)

  readAttribute: (attr) -> @data[attr]
  writeAttribute: (attr, value) -> @data[attr] = value
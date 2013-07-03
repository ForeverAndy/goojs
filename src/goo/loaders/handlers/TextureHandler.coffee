define [
	'goo/loaders/handlers/ConfigHandler'
	
	'goo/renderer/TextureCreator'
	'goo/renderer/Texture'
	'goo/loaders/dds/DdsLoader'
	'goo/loaders/tga/TgaLoader'

	'goo/util/rsvp'
	'goo/util/PromiseUtil'
	'goo/renderer/Util'

	'goo/util/ObjectUtil'
], (
	ConfigHandler,
	TextureCreator,
	Texture,
	DdsLoader,
	TgaLoader,
	RSVP,
	pu,
	ru,
	_
) ->


	class TextureHandler extends ConfigHandler			
		@_register('texture')		

		@loaders:
			dds: DdsLoader
			tga: TgaLoader

		constructor: (@world, @getConfig, @updateObject, @options)->
			@_ddsLoader = new DdsLoader()

		update: (ref, config)->
			_.defaults config, 
				verticalFlip:true
			console.log "Loading texture with url #{config.url}"
			if not config.url
				return pu.createDummyPromise(null)

			imgRef = config.url

			type = imgRef.split('.').pop().toLowerCase()


			if type of TextureHandler.loaders
				textureLoader = new TextureHandler.loaders[type]()
				texture = new Texture(ru.clone(TextureCreator.DEFAULT_TEXTURE_2D.image), config)
				texture.image.dataReady = false
				texture.a = imgRef

				@getConfig(imgRef).then (data)=>
					textureLoader.load(data, texture, config.verticalFlip, 0, data.byteLength)
					return texture

				pu.createDummyPromise(texture)

			else
				texture = new Texture null, config
				@getConfig(imgRef).then (data)=>
					console.log "Adding texture #{imgRef}, data is #{data}"
					texture.setImage(data)
					return texture	
				pu.createDummyPromise(texture)

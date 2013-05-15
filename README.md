#Rez


**Image Manipluation as Service**

Rez is a out-of-box online service for image image manipulation. Built on node stacks, it is ideal for handling image operation IOs.


##API


Please send `GET` requests to API with querystring. Available options for querystring:

###Common Option

  * **mode**(String)

    Existing mode: `ratio`, `resize`, `crop`
  
  * **source**(String)

    URI for source image file image. For the proper `content-type` of the API response, you should garantee either the resource pointed by this URI has correct `contet-type` header or it ends with a proper extention name like `png`, `jpg`
    
  * **quality**(Number)

    Quality of transfomred image


###Ratio Mode

Resize source image by ratio

Options:
  
  * **ratio**(Number), should be less than 1
  

###Resize Mode

Resize source image by width or height

Options: 

  * **resize**(String)
  
  	resize command like "500x100", "400x300"
  	
  * **width**(Number)
  	
  	resize by width
  	
  * **height**(Number)

	resize by height


###Crop Mode

Crop image by given size

Options:
  
  * **width** 
  
  	Width of desired crop
  	
  * **height** 
  	
  	Height of desired crop
  	
  * **gravity**
  
  	Cropping policy that determines which part of original images should remain.
  Possible values: 
  
	* n : North
    * s: South
    * w: West
    * e: East
    * nw: NorthWest
    * ne: NorthEast
    * sw: SouthWest
    * se: SouthEast
    * c: Center

##Heroku

Procfile is included, and by default it starts with clustering:

    heroku create
    git push heroku master
    heroku ps:scale web:1
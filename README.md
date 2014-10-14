Color Dialog
============

A color choosing dialog for Delphi, supporting hls/rgb and showing the selected color channel. The form is in German (but it is easy to translate, since there are only a few nouns. Most of them are color channels, e.g. helligkeit=>brightness, rot=>red, ...)



![changing brightness](http://www.benibela.de/img/sources/farbe.jpg)      ![changing red](http://www.benibela.de/img/sources/farbe2.jpg)

Installation
------------

Just put farbe.pas, farbe.dfm and ExtraListView.pas somewhere in the unit search path.

Usage
------------

The dialog can be created and shown like this:
    
    colorManager:=TcolorManager.create(nil);
    colorManager.addToColorList('',vtCaptionH3);             //Create a header for the colors
    colorManager.addToColorList('color1',vtValue,clRed);     //Create a color option with name color1 and default value clRed
    colorManager.addToColorList('color2',vtValue,clBlue);    //Create a color option with name color2 and default value clBlue
    colorManager.showModal;
    
addToColorList is needed to let the user choose multiple colors in groups.

    
After the dialog has been closed, you can get a changed color with

    colorManager.findInColorList('color1');



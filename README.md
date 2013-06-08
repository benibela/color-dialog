Color Dialog
============

A color choosing dialog for Delphi, supporting hls/rgb and showing the channel. The form is on German (but can be easily translated, as it just are the color channels e.g. helligkeit=>brightness, rot=>red, ...)



![changing brightness](http://www.benibela.de/img/sources/farbe.jpg)      ![changing red](http://www.benibela.de/img/sources/farbe2.jpg)

Installation
------------

Just put farbe.pas, farbe.dfm and ExtraListView.pas somewhere in the unit search path

Usage
------------

The dialog can be created and shown follows.
Since it lets the user choose multiple colors in groups, every color option has to be registered with name before showing.
    
    colorManager:=TcolorManager.create(nil);
    colorManager.addToColorList('',vtCaptionH3);             //Create a header for the colors
    colorManager.addToColorList('color1',vtValue,clRed);     //Create a color option with name color1 and default value clRed
    colorManager.addToColorList('color2',vtValue,clBlue);    //Create a color option with name color2 and default value clBlue
    colorManager.showModal;
    
    
After the dialog has been closed, you can get the changed color with

    colorManager.findInColorList('color1');



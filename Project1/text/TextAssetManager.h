#pragma once
#include "text/TextItem.h"

#include <list>
#include <iostream>

class TextAssetManager
{
public:
	TextAssetManager();
	~TextAssetManager();

	// load
	FontMap* loadFontMap( std::string fontName );
	TextItem* createTextItem( FontMap *map, std::string text );
	static TextItem* makeTextItem( FontMap *map, std::string text );


	// accessor
	std::list<TextItem*>& getTextItems() { return textItems; }
	std::list<FontMap*>& getFontMaps() { return fontMaps; }

	// mutator
	void removeTextItem( TextItem *ti )
	{
		if( ti == NULL ) return;
		textItems.remove( ti );
		delete ti;
	}


private:

	std::list<TextItem*> textItems;
	std::list<FontMap*> fontMaps;
};
#include "TextAssetManager.h"

using namespace std;


TextAssetManager::TextAssetManager()
{

}

TextAssetManager::~TextAssetManager()
{

}

FontMap* TextAssetManager::loadFontMap( string fontName )
{
	FontMap *map = FontMap::loadFontMapFromFile( fontName );
	if( map == NULL ) return NULL;
	fontMaps.push_back( map );
	return map;
}


TextItem* TextAssetManager::createTextItem( FontMap *map, string text )
{
	if( map == NULL ) return NULL;

	TextItem *ti = new TextItem( map, text );
	textItems.push_back( ti );
	return ti;
}

TextItem* TextAssetManager::makeTextItem( FontMap *map, string text )
{
	TextItem *ti = new TextItem( map, text );
	return ti;
}



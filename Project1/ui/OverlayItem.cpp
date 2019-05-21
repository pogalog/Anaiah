#include "OverlayItem.h"
#include "Overlay.h"
#include "text/TextAssetManager.h"


OverlayItem::OverlayItem( Overlay *overlay, std::string message )
	:overlay( overlay ), text( TextAssetManager::makeTextItem( overlay->getFont(), message ) ), visible( true )
{
}
OverlayItem::~OverlayItem()
{

}
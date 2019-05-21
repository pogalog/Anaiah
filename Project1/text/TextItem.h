#pragma once

#include <string>
#include "FontMap.h"
#include "model/Model.h"
#include "render/Color.h"

class Shader;
class TextItem
{
public:
	TextItem( FontMap *map, std::string text );
	~TextItem();

	// main
	void draw( const Camera& );


	// accessor
	const FontMap* getFontMap() const { return fontMap; }
	float getWidth() const { return size * width; }
	float getSize() const { return size; }
	Model& getModel() { return model; }
	bool is2D() { return toodee; }
	bool isVisible() { return visible; }
	Transform& getTransform() { return model.transform; }
	std::string& getText() { return text; }
	Color& getColor() { return color; }

	// mutator
	void set2D( bool make2D ) { toodee = make2D; }
	void setText( std::string text );
	void setVisible( bool visible ) { this->visible = visible; }
	void setColor( Color c ) { this->color = c; }


private:
	void buildModel();


	FontMap *fontMap;
	Color color;
	std::string text;
	float size, width;
	Model model;
	bool visible, toodee;
	Shader *shader;
};
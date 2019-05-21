#include "TileRange.h"
#include "MapTile.h"
#include "model/ModelUtil.h"
#include "glm/glm.hpp"

using namespace glm;

void TileRange::draw( const Camera &camera )
{
	if( shader == NULL ) return;
	if( !model.visible ) return;

	Mesh &mesh = model.getPrimaryMesh();

	if( !mesh.visible ) return;

	glUseProgram( shader->programID );

	// compute matrices
	mat4 shiftUp = mat4( 1.0 );
	shiftUp[3][1] = 0.05f;
	mat4 modelviewMatrix = camera.transform.matrix * shiftUp;
	mat4 modelviewProjectionMatrix = camera.lens.projectionMatrix * modelviewMatrix;

	// assign uniform values
	glUniformMatrix4fv( glGetUniformLocation( shader->programID, "MVP" ), 1, GL_FALSE, &modelviewProjectionMatrix[0][0] );
	glUniform4f( glGetUniformLocation( shader->programID, "color" ), color.r(), color.g(), color.b(), color.a() );

	glEnableVertexAttribArray( 0 );
	glBindVertexArray( mesh.name );
	glDrawArrays( GL_TRIANGLES, 0, mesh.numElements );
	glBindVertexArray( 0 );
	glDisableVertexAttribArray( 0 );
}


void TileRange::buildModel()
{
	model_util::createRangeModel( tiles, model );
}


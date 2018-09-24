//
// This file is a part of the Chunk Stories Core codebase
// Check out README.md for more information
// Website: http://chunkstories.xyz
//

package io.xol.chunkstories.core.voxel;

import io.xol.chunkstories.api.physics.Box;
import io.xol.chunkstories.api.voxel.Voxel;
import io.xol.chunkstories.api.voxel.VoxelDefinition;
import io.xol.chunkstories.api.voxel.VoxelSide;
import io.xol.chunkstories.api.world.cell.CellData;

public class Voxel8Steps extends Voxel {
	//VoxelModel[] steps = new VoxelModel[8];

	public Voxel8Steps(VoxelDefinition type) {
		super(type);
		//for (int i = 0; i < 8; i++)
		//	steps[i] = store().models().getVoxelModel("steps.m" + i);
	}

	/*@Override
	public VoxelRenderer getVoxelRenderer(CellData info) {
		// return nextGen;
		return steps[info.getMetaData() % 8];
	}*/

	@Override
	public boolean isFaceOpaque(VoxelSide side, int data) {
		if (side == VoxelSide.BOTTOM)
			return true;
		if (side == VoxelSide.TOP)
			return true;

		return super.isFaceOpaque(side, data);
	}

	@Override
	public Box[] getCollisionBoxes(CellData info) {
		Box box2 = new Box(1, (info.getMetaData() % 8 + 1) / 8f, 1);
		return new Box[] { box2 };
	}
}

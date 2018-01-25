package io.xol.chunkstories.core.converter.mappings;

import io.xol.chunkstories.api.content.ContentTranslator;
import io.xol.chunkstories.api.converter.mappings.NonTrivialMapper;
import io.xol.chunkstories.api.voxel.Voxel;
import io.xol.chunkstories.api.voxel.VoxelFormat;
import io.xol.chunkstories.api.voxel.VoxelSides;
import io.xol.chunkstories.api.world.World;
import io.xol.chunkstories.api.world.chunk.Chunk;
import io.xol.chunkstories.core.voxel.VoxelDoor;
import io.xol.enklume.MinecraftRegion;

public class Door extends NonTrivialMapper {

	public Door(Voxel voxel, ContentTranslator translator) {
		super(voxel, translator);
	}

	@Override
	public void output(World csWorld, int csX, int csY, int csZ, int minecraftBlockId, int minecraftMetaData, MinecraftRegion region,
			int minecraftCuurrentChunkXinsideRegion, int minecraftCuurrentChunkZinsideRegion, int x, int y, int z) {
		
		Chunk chunk = csWorld.getChunkWorldCoordinates(csX, csY, csZ);
		assert chunk != null;
		
		int upper = (minecraftMetaData & 0x8) >> 3;
		int open = (minecraftMetaData & 0x4) >> 2;
		
		//We only place the lower half of the door and the other half is created by the placing logic of chunk stories
		if (upper != 1)
		{
			int upperMeta = region.getChunk(minecraftCuurrentChunkXinsideRegion, minecraftCuurrentChunkZinsideRegion).getBlockMeta(x, y + 1, z);
			
			int hingeSide = upperMeta & 0x01;
			
			int direction = minecraftMetaData & 0x3;
			int baked = VoxelFormat.format(voxelID, VoxelDoor.computeMeta(open == 1, hingeSide == 1, VoxelSides.getSideMcDoor(direction)), 0, 0);
			
			csWorld.pokeRawSilently(csX, csY, csZ, baked);

		}
		else
			return;
		
	}
}
package com.watabou.utils;

class PerlinNoise {
	private static var permutation = [
		151,160,137,91,90,15,
		131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
		190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
		88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
		77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
		102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
		135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
		5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
		223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
		129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
		251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
		49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
		138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
	];

	private static var ease	: Array<Float>;

	private var p	: Array<Int>;

	public function new( seed:Int ) {
		p = [for (i in 0...256) permutation[(i + seed) % 256]];
		p = p.concat( p );

		if (ease == null) {
			ease = [];
			for (i in 0...256) {
				var t = i / 256;
				ease.push( t * t * t * (t * (6 * t - 15) + 10));
			}
		}
	}

	private inline function dot( hash:Int, x:Float, y:Float ):Float {
		return switch (hash & 3) {
			case 0	:  x +y;
			case 1	:  x -y;
			case 2	: -x +y;
			case 3	: -x -y;
			default	: 0;
		}
	}

	private inline function interpolate( a:Float, b:Float, w:Float ):Float {
		return a + (b - a) * w;
	}

	public function noise( x:Float, y:Float, gridSize:Float=1 ) {

		var j0 = Std.int( x );
		var j1 = j0 + 1;

		var fx = x - j0;
		var wx = ease[Std.int( fx * 256 )];

		var i0 = Std.int( y );
		var i1 = i0 + 1;

		var fy = y - i0;
		var wy = ease[Std.int( fy * 256 )];

		var aa = this.p[this.p[j0]+i0];
		var ab = this.p[this.p[j1]+i0];
		var ba = this.p[this.p[j0]+i1];
		var bb = this.p[this.p[j1]+i1];

		var v0 = this.dot( aa, fx, fy );
		var v1 = this.dot( ab, fx - 1, fy );
		var val0 = this.interpolate( v0, v1, wx );
		var v0 = this.dot( ba, fx, fy - 1 );
		var v1 = this.dot( bb, fx - 1, fy - 1 );
		var val1 = this.interpolate( v0, v1, wx );

		return this.interpolate( val0, val1, wy );
	}

	public function noiseMap( width:Int, height:Int, gridSize:Float=1 ):Array<Array<Float>> {
		var grid = [for (i in 0...height) [for (j in 0...width) 0.0]];
		var index = 0;

		var xStep = gridSize / width;
		var yStep = gridSize / height;

		var y = 0.0;
		for (i in 0...height) {

			var i0 = Std.int( y );
			var i1 = i0 + 1;

			var fy = y - i0;
			var wy = ease[Std.int( fy * 256 )];

			var x = 0.0;
			for (j in 0...width) {

				var j0 = Std.int( x );
				var j1 = j0 + 1;

				var fx = x - j0;
				var wx = ease[Std.int( fx * 256 )];

				var aa = this.p[this.p[j0]+i0];
				var ab = this.p[this.p[j1]+i0];
				var ba = this.p[this.p[j0]+i1];
				var bb = this.p[this.p[j1]+i1];

				var v0 = this.dot( aa, fx, fy );
				var v1 = this.dot( ab, fx - 1, fy );
				var val0 = this.interpolate( v0, v1, wx );
				var v0 = this.dot( ba, fx, fy - 1 );
				var v1 = this.dot( bb, fx - 1, fy - 1 );
				var val1 = this.interpolate( v0, v1, wx );

				grid[i][j] = this.interpolate( val0, val1, wy );

				x += xStep;
			}

			y += yStep;
		}

		return grid;
	}

	public function noiseHigh( x:Float, y:Float, octaves:Int, gridSize:Float=1, persistance:Float=0.5 ):Float {
		var result = noise( x, y, gridSize );

		var amplitude = persistance;
		for (i in 1...octaves) {
			// INCORRECT! x & y should be updated as well
			result += noise( x, y, gridSize*=2 ) * amplitude;
			trace( result, gridSize, amplitude );
			amplitude *= persistance;
		}

		return result;
	}

	public function noiseMapHigh( width:Int, height:Int, octaves:Int, gridSize:Float=1, persistance:Float=0.5 ) {
	/*	var grid = [for (i in 0...height) [for (j in 0...width) 0.0]];
		var index = 0;

		var xStep = gridSize / width;
		var yStep = gridSize / height;

		var y = 0.0;
		for (i in 0...height) {
			var x = 0.0;
			for (j in 0...width) {
				grid[i][j] = noiseHigh( x, y, octaves, gridSize, persistance );
				x += xStep;
			}
			y += yStep;
		}

		return grid;*/
		var result = this.noiseMap( width, height, gridSize );

		var amplitude = persistance;
		for (i in 1...octaves) {
			var o = noiseMap( width, height, gridSize*=2 );
			for (y in 0...height) {
				for (x in 0...width) {
					result[y][x] += o[y][x] * amplitude;
				}
			}
			amplitude *= persistance;
		}

		return result;
	}
}
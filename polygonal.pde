int screenX = 600;
int screenY = 400;
int seed;
float time = 0;
boolean redraw = false;

void setup() {
	size(screenX, screenY, P2D);
	redraw = true;

	//seed = 100;
	seed = round(random(0, 1000000));
}

void draw() {
	smooth();
	drawCurved();
}

void drawCurved() {
	if (redraw) {
		background(255);
		PImage img = generateNoise(time, seed);
		//image(img, 0, 0);
		color fillColor = color(199, 244, 100);

		ArrayList<ArrayList<PVector>> groups = groupPoints(img, 20);
		for (ArrayList<PVector> pts : groups) {
			//image(drawEdgePoints(img, pts, color(255, 0, 0)), 0, 0);
			//image(drawEdgePoints(img, groups.get(0), color(0, 0, 255)), 0, 0);

			// we need to sort the points first
			println("points: " + pts.size());
			Phull.heapsort(pts, pts.size());
			println("points post: " + pts.size());
			pts = Phull.MonotoneChain(pts);
			println("edge points: " + pts.size());
			//pts = Phull.ProximityChain(pts, 10);

			// draw the hull
			PShape hull = createShape();
			hull.beginShape();
			hull.stroke(0);
			hull.strokeWeight(2);
			hull.fill(fillColor);

			for (PVector p : pts) {
				hull.vertex(p.x, p.y);
			}

			hull.endShape(CLOSE);
			shape(hull);
		}

		redraw = false;
	}

	increment();
}

void drawBoxy() {
	if (redraw) {
		background(255);
		PImage img = generateNoise(time, seed);
		color fillColor = color(199, 244, 100);

		ArrayList<ArrayList<PVector>> groups = groupPoints(img, 20);
		for (ArrayList<PVector> pts : groups) {

			// we need to sort the points first
			Phull.heapsort(pts, pts.size());
			pts = Phull.MonotoneChain(pts);
			pts = Boxify(pts);

			// draw the hull
			PShape hull = createShape();
			hull.beginShape();
			hull.stroke(0);
			hull.strokeWeight(2);
			hull.fill(fillColor);

			for (PVector p : pts) {
				hull.vertex(p.x, p.y);
			}

			hull.endShape(CLOSE);
			shape(hull);
		}

		redraw = false;
	}

	increment();
}

// turns a list of polygon vertices into a box
private ArrayList<PVector> Boxify(List<PVector> points) {
	// find the bounding box
	float minX = float.MAX_VALUE;
	float minY = float.MAX_VALUE;
	float maxX = 0;
	float maxY = 0;

	PVector pMaxX = new PVector(0, 0);
	PVector pMaxY = new PVector(0, 0);
	PVector pMinX = new PVector(0, 0);
	PVector pMinY = new PVector(0, 0);

	for (PVector p : points) {
		if (p.x > maxX) {
			maxX = p.x;
			pMaxX = p;
		}

		if (p.y > maxY) {
			maxY = p.y;
			pMaxY = p;
		}

		if (p.x < minX) {
			minX = p.x;
			pMinX = p;
		}

		if (p.y < minY) {
			minY = p.y;
			pMinY = p;
		}
	}

	return new ArrayList<PVector>() {
		pMaxX,
		pMaxY,
		pMinX,
		pMinY
	};
}

void mouseClicked() {
	//increment();
}

void increment() {
	save("images/img_" + System.currentTimeMillis() + ".png");
	time += .025;
	redraw = true;
}

// ## Algorithm steps:
// 1. generation of random noise cloud (perlin?, b/w pixels)
// 2. coalesce pixels to make larger shapes
// 3. analyze pixels (edge-detection) to find edge points
// 4. use a convex hull algorithm to convert pixel clouds to polygons
// 5. color and draw the polygon
// 6. repeat steps 1-5 for each color layer

// ## generateNoise()
// Generates quantized perlin noise, suitable for polygon generation
private PImage generateNoise(float t, int seed) {
	PImage img = createImage(screenX, screenY, RGB);
	img.loadPixels();

	float increment = .2;
	float xOffset = 0;
	float yOffset = 0;
	float scale = 5;

	// ensure seed is random
	noiseSeed(seed);
	noiseDetail(2, .5);

	for (int x = 0; x < screenX; x++) {
		xOffset += increment;
		yOffset = 0;
		for (int y = 0; y < screenY; y++) {
			yOffset += increment;
			float val = noise(((float)x / screenX) * scale, ((float)y / screenY) * scale, t);
			// quantize the value
			val = round(map(val, 0, 1, 1, 2));
			if (val == 2) {
				val = 0;
			}
			img.pixels[x + y * screenX] = color(val * 255);
		}
	}

	img.updatePixels();

	return img;
}

// ## crappyEdgeDetection(PImage img)
// Returns a list of edge points,
// using a scanline method and only brightness as a determining factor
// (I told you it was crappy)
// TODO:
//	* determine if left or right edge
//	* group into shapes
private ArrayList<PVector> crappyEdgeDetection(PImage img) {
	float lastBrightness = brightness(img.pixels[0]);
	float curBrightness;
	ArrayList<PVector> edgePoints = new ArrayList<PVector>();
	for (int y = 0; y < img.height; y++) {
		for (int x = 0; x < img.width; x++) {
			curBrightness = brightness(img.pixels[x + y * img.width]);
			if (x > 0 && curBrightness != lastBrightness) {
				// found the edge
				edgePoints.add(new PVector(x, y));
			}
			else if (y > 0) {
				if (curBrightness != brightness(img.pixels[x + (y - 1) * img.width])) {
					// found the edge
					edgePoints.add(new PVector(x, y));
				}
			}

			lastBrightness = curBrightness;
		}
	}

	return edgePoints;
}

// ## crappyEdgeDetection(PImage img)
// Returns a list of edge points,
// using a scanline method and only brightness as a determining factor
// (I told you it was crappy)
// TODO:
//	* determine if left or right edge
//	* group into shapes
/*
private ArrayList<PVector> crappyEdgeDetectionGroup(PImage img) {
	float lastBrightness = brightness(img.pixels[0]);
	float curBrightness;
	boolean isLeft = false;

	ArrayList<ArrayList<PVector>> groups = new ArrayList<ArrayList<PVector>>();
	for (int y = 0; y < img.height; y++) {
		for (int x = 0; x < img.width; x++) {
			curBrightness = brightness(img.pixels[x + y * img.width]);
			PVector p = new PVector(x, y);

			if (x > 0 && curBrightness != lastBrightness) {
				// found the edge
				edgePoints.add(new PVector(x, y));
			}

			lastBrightness = curBrightness;

			if (y > 0) {
				if (curBrightness != brightness(img.pixels[x + (y - 1) * img.width])) {
					// found the edge
					edgePoints.add(new PVector(x, y));
					isLeft = !isLeft;
				}
			}
		}
	}

	return edgePoints;
}
*/

// downsample
private ArrayList<PVector> downsamplePoints(ArrayList<PVector> pts, int factor) {
	ArrayList<PVector> downsampled = new ArrayList<PVector>();
	for (int i = 0; i < pts.size(); i++) {
		if (i % factor == 0) {
			downsampled.add(pts.get(i));
		}
	}

	return downsampled;
}

// highlight detected edges
private PImage drawEdgePoints(PImage img, ArrayList<PVector> pts, color c) {
	img.loadPixels();
	for (PVector p : pts) {
		img.pixels[int(p.x) + int(p.y) * img.width] = c;
	}

	img.updatePixels();

	return img;
}

// ## groupPoints
// Creates groups of points from an image.
// These groups define concrete shapes.
// Color image and check proximity to color points.
// Args:
// * img: the image to search
// * groupCount: max number of groups to identify
private ArrayList<ArrayList<PVector>> groupPoints(PImage img, int groupCount) {
	ArrayList<ArrayList<PVector>> groups = new ArrayList<ArrayList<PVector>>();
	ArrayList<PVector> group = new ArrayList<PVector>();

	img.loadPixels();
	color targetColor = color(0);
	float lastBrightness = brightness(img.pixels[0]);
	int proximity = 1;

	// map image used to track progress
	// each group is given a unique color
	PImage map = createImage(img.width, img.height, RGB);
	map.loadPixels();
	for (int i = 0; i < map.pixels.length; i++) {
		map.pixels[i] = color(255);
	}
	
	int groupId = 1;
	color groupColor = color(1, 0, 0);

	boolean isInit = false;

	for (int i = 0; i < groupCount; i++) {
		ArrayList<PVector> edgePoints = new ArrayList<PVector>();
		for (int y = 0; y < img.height; y++) {
			for (int x = 0; x < img.width; x++) {
				if (img.pixels[x + y * img.width] == targetColor) {
					// check if next to desired color
					if (!isInit || pixelBoxCheck(map, x, y, proximity, groupColor)) {
						group.add(new PVector(x, y));

						//println(">> " + x + " | " + y);
						img.pixels[x + y * img.width] = color(255, 0, 0);

						// track pixel
						map.pixels[x + y * img.width] = groupColor;
						map.updatePixels();
						isInit = true;
					}
				}
			}
		}

		// reverse sweep
		for (int y = img.height - 1; y >= 0; y--) {
			for (int x = img.width - 1; x >= 0; x--) {
				if (img.pixels[x + y * img.width] == targetColor) {
					// check if next to desired color
					if (!isInit || pixelBoxCheck(map, x, y, proximity, groupColor)) {
						group.add(new PVector(x, y));

						//println(">> " + x + " | " + y);
						img.pixels[x + y * img.width] = color(255, 0, 0);

						// track pixel
						map.pixels[x + y * img.width] = groupColor;
						map.updatePixels();
						isInit = true;
					}
				}
			}
		}

		// end of group
		groups.add(group);
		group = new ArrayList<PVector>();
		groupId++;
		groupColor = color(groupId, 0, 0);
		isInit = false;
	}

	//println("group size: " + group.size());

	return groups;
}

// ## pixelBoxCheck
// Searches a square centered around the pixel 
public boolean pixelBoxCheck(PImage img, int centerX, int centerY, int radius, color search) {
	//img.loadPixels();
	boolean found = false;
	int width = img.width;
	int startX = constrain(centerX - radius, 0, img.width);
	int startY = constrain(centerY - radius, 0, img.height);
	int endX = constrain(centerX + radius, 0, img.width - 1);
	int endY = constrain(centerY + radius, 0, img.height - 1);

	for (int x = startX; x <= endX; x++) {
		for (int y = startY; y <= endY; y++) {
			if (img.pixels[x + y * width] == search) {
				found = true;
				break;
			}
		}
	}

	return found;
}

private boolean isPartOfCloud(PVector point, ArrayList<PVector> pts, float proximity, PImage img) {
	// assuming points are close together
	// collinear => same cloud?
	img.loadPixels();
	for (int i = 0; i < pts.size(); i++) {
		if (PVector.dist(pts.get(i), point) <= proximity) {

			// check if whitespace exists between the two points
			PVector vDiff = PVector.sub(point, pts.get(i));
			vDiff.normalize();
			vDiff.add(point);

			int x = round(vDiff.x);
			int y = round(vDiff.y);
			if (brightness(img.pixels[x + y * screenX]) > 0) {
				// skip this point
				continue;
			}

			return true;
		}
	}

	return false;
}

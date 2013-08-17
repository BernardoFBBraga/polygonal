# Polygonal

Perlin noise polygons in Processing.
We start by generating Perlin noise that is quantized to black and white to allow for easier shape identification.

Then we:

1. Create groups of points by grouping the black pixels together with a simple radius check.
2. Heapsort the points along the X, then Y, axes.
3. Pass each group of points into a Andrew's Monotone Chain function (a convex hull algorithm, similar to Graham Scan).
4. Each group is of points is now a convex hull, so we can now draw a polygon for each one.
5. ???
6. ART

For the boxy drawing method there are a few steps between 3 and 4:

- Determine the bounding box for each polygon.
- Treat each line of the box as a tangent line.
- Connect the points that intersect the tangents, creating a triangle or quadrilateral.

 This project includes some code that may be helpful in other cases as well; `Phull.java` includes convex hull and heapsort implementations.

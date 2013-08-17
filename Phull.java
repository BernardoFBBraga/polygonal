import processing.core.*;
import java.util.*;

// # Phull
// A convex hull library for Processing (__P__rocessing __H__ull)
public class Phull {
	// ## MonotoneChain
	// An Andrew's monotone chain convex hull algorithm.
	// The points need to already sorted by x, then y, values.
	// (This is already done if the points are image pixel coordinates in original order)
	public static ArrayList<PVector> MonotoneChain(ArrayList<PVector> points) {
		// easy win
		if (points.size() <= 1) {
			return points;
		}

		ArrayList<PVector> lower  = new ArrayList<PVector>();
		for (PVector p : points) {
			while (lower.size() >= 2 &&
					Cross(lower.get(lower.size() - 2), lower.get(lower.size() - 1), p).z <= 0) {
				lower.remove(lower.size() - 1);
			}
			lower.add(p);
		}
		
		ArrayList<PVector> upper = new ArrayList<PVector>();
		for (int i = points.size() - 1; i >= 0; i--) {
			PVector p = points.get(i);

			while (upper.size() >= 2 &&
					Cross(upper.get(upper.size() - 2), upper.get(upper.size() - 1), p).z <= 0) {
				upper.remove(upper.size() - 1);
			}
			upper.add(p);
		}

		// trim last element off of each list
		// since they are duplicated at the beginning of the other
		lower.remove(lower.size() - 1);
		upper.remove(upper.size() - 1);

		// concat lists
		lower.addAll(upper);

		return lower;
	}

	// ## ProximityChain
	// An Andrew's monotone chain convex hull algorithm implementation,
	// with an added proximity check.
	// The points need to already sorted by x, then y, values.
	// (This is already done if the points are image pixel coordinates)
	public static ArrayList<PVector> ProximityChain(ArrayList<PVector> points, float proximity) {
		// easy win
		if (points.size() <= 1) {
			return points;
		}

		ArrayList<PVector> lower  = new ArrayList<PVector>();
		for (PVector p : points) {
			while (lower.size() >= 2 &&
				lower.get(lower.size() - 2).dist(lower.get(lower.size() - 1)) > proximity ) {
				lower.remove(lower.size() - 2);
			}

			while (lower.size() >= 2 &&
					Cross(lower.get(lower.size() - 2), lower.get(lower.size() - 1), p).z <= 0) {
				lower.remove(lower.size() - 1);
			}
			lower.add(p);
		}
		
		ArrayList<PVector> upper = new ArrayList<PVector>();
		for (int i = points.size() - 1; i >= 0; i--) {
			PVector p = points.get(i);

			while (upper.size() >= 2 &&
				upper.get(upper.size() - 2).dist(upper.get(upper.size() - 1)) > proximity ) {
				upper.remove(upper.size() - 2);
			}

			while (upper.size() >= 2 &&
					Cross(upper.get(upper.size() - 2), upper.get(upper.size() - 1), p).z <= 0) {
				upper.remove(upper.size() - 1);
			}
			upper.add(p);
		}

		// trim last element off of each list
		// since they are duplicated at the beginning of the other
		lower.remove(lower.size() - 1);
		upper.remove(upper.size() - 1);

		// concat lists
		lower.addAll(upper);

		return lower;
	}

	// ## Cross
	// Cross product of the vectors origin => p1 and origin => p2
	public static PVector Cross(PVector origin, PVector p1, PVector p2) {
		PVector o1 = PVector.sub(p1, origin);
		PVector o2 = PVector.sub(p2, origin);

		return o1.cross(o2);
	}

	// ## heapsort
	public static void heapsort(List<PVector> points, int count) {
		// default comparator: x then y
		Comparator<PVector> comparator = new Comparator<PVector>() {
			public int compare(PVector p1, PVector p2) {
				if (p1.x < p2.x) {
					return -1;
				}

				if (p1.x > p2.x) {
					return 1;
				}

				// equal x values
				// so check y
				if (p1.y < p2.y) {
					return -1;
				}

				if (p1.y > p2.y) {
					return 0;
				}

				// truly the same
				return 0;
			}
		};

		heapsort(points, count, comparator);
	}

	// ## heapsort
	public static void heapsort(List<PVector> points, int count, Comparator<PVector> comparator) {
		heapify(points, count, comparator);

		int end = count - 1;
		while (end > 0) {
			// swap the root (max value) with the last element of the heap
			swap(points, end, 0);

			// effectively decrease heap size that sorted value will stay in place
			end--;

			// re-order the heap
			siftDown(points, 0, end, comparator);
		}
	}
	
	// ## heapify(List<PVector> points, int count, Comparator<PVector> comparator)
	// Creates a heap structure from 'points'.
	public static void heapify(List<PVector> points, int count, Comparator<PVector> comparator) {
		int start = (count - 2) / 2;
		while (start >= 0) {
			siftDown(points, start, count - 1, comparator);
			start--;
		}
	}

	// ## swap(List<PVector> points, int a, int b)
	// I shouldn't have to explain this.
	public static void swap(List<PVector> points, int a, int b) {
		PVector temp = points.get(a);
		points.set(a, points.get(b));
		points.set(b, temp);
	}

	public static void siftDown(List<PVector> points, int start, int end, Comparator<PVector> comparator) {
		int root = start;
		while (root * 2 + 1 <= end) {
			int child = root * 2 + 1;
			int swap = root;

			// check if root is smaller than left child
			if (comparator.compare(points.get(swap), points.get(child)) == -1) {
				swap = child;
			}

			// check if root is smaller than right child
			if (child + 1 <= end &&
					comparator.compare(points.get(swap), points.get(child + 1)) == -1) {
				swap = child + 1;
			}

			if (swap != root) {
				// swap the elements
				swap(points, root, swap);
				root = swap;
				// continue sifting
			}
			else {
				return;
			}
		}
	}
}

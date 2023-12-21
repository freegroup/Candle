from kivy_garden.mapview import MapLayer
from kivy.graphics import Color, Line, Ellipse

from kivy.graphics.context_instructions import Translate, Scale, PushMatrix, PopMatrix
from kivy_garden.mapview.utils import clamp
from kivy_garden.mapview.constants import (MIN_LONGITUDE, MAX_LONGITUDE, MIN_LATITUDE, MAX_LATITUDE)
from math import radians, log, tan, cos, pi

from utils.route import Route

class LineMapLayer(MapLayer):
    def __init__(self, route: Route, color=[0, 0, 1, 1], **kwargs):
        super().__init__(**kwargs)
        self._route = route
        self.color = color
        self._line_points = None
        self._line_points_offset = (0, 0)
        self.zoom = 0
        self.lon = 0
        self.lat = 0
        self.ms = 0

    @property
    def route(self):
        return self._route

    @route.setter
    def route(self, route):
        self._route = route
        self.invalidate_line_points()
        self.clear_and_redraw()

    @property
    def line_points(self):
        if self._line_points is None:
            self.calc_line_points()
        return self._line_points

    @property
    def line_points_offset(self):
        if self._line_points is None:
            self.calc_line_points()
        return self._line_points_offset

    def calc_line_points(self):
        # Offset all points by the coordinates of the first point,
        # to keep coordinates closer to zero.
        # (and therefore avoid some float precision issues when drawing lines)
        poi = self.route.points[0]
        self._line_points_offset = (self.get_x(poi.lon), self.get_y(poi.lat))
        # Since lat is not a linear transform we must compute manually
        self._line_points = [
            (self.get_x(poi.lon) - self._line_points_offset[0],
             self.get_y(poi.lat) - self._line_points_offset[1],
             (0, 1,0,1) if self.route.is_special_coordinate(poi) else (1,0,0,1))
            for poi in self.route.points
        ]

    def invalidate_line_points(self):
        self._line_points = None
        self._line_points_offset = (0, 0)

    def get_x(self, lon):
        """Get the x position on the map using this map source's projection
        (0, 0) is located at the top left.
        """
        return clamp(lon, MIN_LONGITUDE, MAX_LONGITUDE) * self.ms / 360.0

    def get_y(self, lat):
        """Get the y position on the map using this map source's projection
        (0, 0) is located at the top left.
        """
        lat = radians(clamp(-lat, MIN_LATITUDE, MAX_LATITUDE))
        return (1.0 - log(tan(lat) + 1.0 / cos(lat)) / pi) * self.ms / 2.0

    # Function called when the MapView is moved
    def reposition(self):
        map_view = self.parent

        # Must redraw when the zoom changes
        # as the scatter transform resets for the new tiles
        if self.zoom != map_view.zoom or \
                   self.lon != round(map_view.lon, 7) or \
                   self.lat != round(map_view.lat, 7):
            map_source = map_view.map_source
            self.ms = pow(2.0, map_view.zoom) * map_source.dp_tile_size
            self.invalidate_line_points()
            self.clear_and_redraw()

    def clear_and_redraw(self, *args):
        with self.canvas:
            # Clear old line
            self.canvas.clear()

        self._draw_line()

    def _draw_line(self, *args):
        map_view = self.parent
        self.zoom = map_view.zoom
        self.lon = map_view.lon
        self.lat = map_view.lat

        # When zooming we must undo the current scatter transform
        # or the animation distorts it
        scatter = map_view._scatter
        sx, sy, ss = scatter.x, scatter.y, scatter.scale

        # Account for map source tile size and map view zoom
        vx, vy, vs = map_view.viewport_pos[0], map_view.viewport_pos[1], map_view.scale

        with self.canvas:

            # Save the current coordinate space context
            PushMatrix()

            # Offset by the MapView's position in the window (always 0,0 ?)
            Translate(*map_view.pos)

            # Undo the scatter animation transform
            Scale(1 / ss, 1 / ss, 1)
            Translate(-sx, -sy)

            # Apply the get window xy from transforms
            Scale(vs, vs, 1)
            Translate(-vx, -vy)

            # Apply what we can factor out of the mapsource long, lat to x, y conversion
            Translate(self.ms / 2, 0)

            # Translate by the offset of the line points
            # (this keeps the points closer to the origin)
            Translate(*self.line_points_offset)

            Color(*self.color)
            Line(points=[ (coord[0], coord[1]) for coord in self.line_points ], width=2)

            # Draw a circle at the start and end of the line
            circle_size = 20  # 4 times the line width, adjust as needed
            for point in self.line_points:
                # Draw circle at each vertex point
                Color(*point[2])  # Red color for the circle
                Ellipse(pos=(point[0] - circle_size / 2, point[1] - circle_size / 2), size=(circle_size, circle_size))
    
            # Retrieve the last saved coordinate space context
            PopMatrix()

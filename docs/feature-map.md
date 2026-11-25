# Feature map

Every public entry point of gimp-mcp. The repo is an MCP server (`gimp_mcp_server.py`) that forwards each tool call as a JSON line to a socket server running inside GIMP (`gimp-mcp-plugin.py`, `localhost:9877`).

Rows were run on 2026-11-25 on a machine with no GIMP. Each tool row was reached by calling the tool through the server against a stand-in socket on `127.0.0.1:9877` that records the command type and replies `{"status":"success"}`. The "plugin receives" check in each row is that recorded command. The effect inside GIMP (the "With real GIMP" half of each check) was not run against a real GIMP. `get_image_bitmap` and `get_state_snapshot` reached the plugin command but raised, because the stand-in returns no image data.

To run the server: `uv run python gimp_mcp_server.py` (stdio MCP). `uv run` needs Python 3.12 or 3.13 for the locked `pydantic-core` wheel (`uv run --python 3.12 --frozen ...`).

## Entry points

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| MCP server over stdio | `gimp_mcp_server.py` `main()`; console script `gimp-mcp-server` | `uv run --python 3.12 python gimp_mcp_server.py`, or register it in an MCP client (see README) | Connect a stdio MCP client, `initialize`, `list_tools`: returns the tools below. Run here: 79 tools listed, `check_server` returns `{"connected": false, ...}` with no GIMP |
| Prompt: GIMP best practices | `gimp_mcp_server.py` `gimp_best_practices`, text in `docs/best_practices.md` | MCP `prompts/get` name `gimp_best_practices` | Returns the file text (9724 characters when run here) |
| Prompt: iterative workflow | `gimp_mcp_server.py` `gimp_iterative_workflow`, text in `docs/iterative_workflow.md` | MCP `prompts/get` name `gimp_iterative_workflow` | Returns the file text (8873 characters when run here) |
| GIMP plugin: Start / Check / Restart MCP Server | `gimp-mcp-plugin.py` | Inside GIMP 3.2: Tools > MCP > Start MCP Server (also Check and Restart) | Not run, GIMP is not installed here. With GIMP: `python3 -c "import socket;socket.create_connection(('127.0.0.1',9877))"` exits 0 after Start |
| Integration test suite | `run_tests.py` | `python3 run_tests.py` with the plugin running | Not run against GIMP. Without the plugin it fails with `ConnectionRefusedError` on port 9877 |
| add_text metadata regression test | `tests/test_add_text_metadata.py` | `python3 tests/test_add_text_metadata.py` with the plugin running | Not run against GIMP. Exits 0 on pass, 1 on fail |
| Background removal script | `bg_remove.py` | `python bg_remove.py --input in.png --output out.png` | `--help` run here and prints usage. Processing needs the plugin |
| Iterative background removal script | `bg_remove_iterative.py` | `python bg_remove_iterative.py --input in.png --output-dir out/` | `--help` run here and prints usage. Processing needs the plugin |
| Agent edit demo script | `agent_edit_demo.py` | `python agent_edit_demo.py --input portrait.png --output-dir out/` | `--help` run here and prints usage. Processing needs the plugin |

## MCP tools

### Connection and info

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Check whether the GIMP MCP plugin socket is reachable and responding | `gimp_mcp_server.py:91` `check_server` | MCP tool `check_server` | Tool returns without error and the plugin receives command `get_gimp_info`. With real GIMP the result carries the live GIMP state described in the docstring. |
| Drop and re-establish the connection to the GIMP MCP plugin | `gimp_mcp_server.py:114` `restart_server` | MCP tool `restart_server` | Tool returns without error and the plugin receives command `get_gimp_info`. With real GIMP the result carries the live GIMP state described in the docstring. |
| Get comprehensive information about the GIMP installation and environment | `gimp_mcp_server.py:279` `get_gimp_info` | MCP tool `get_gimp_info` | Tool returns without error and the plugin receives command `get_gimp_info`. With real GIMP the result carries the live GIMP state described in the docstring. |
| Get the current GIMP context state (colors, brush, settings) | `gimp_mcp_server.py:369` `get_context_state` | MCP tool `get_context_state` | Tool returns without error and the plugin receives command `get_context_state`. With real GIMP the result carries the live GIMP state described in the docstring. |
| Call GIMP 3.2 API methods through PyGObject console | `gimp_mcp_server.py:406` `call_api` | MCP tool `call_api` | Tool returns without error and the plugin receives command `call_api`. With real GIMP the result carries the live GIMP state described in the docstring. |
| List all images currently open in GIMP | `gimp_mcp_server.py:2534` `list_images` | MCP tool `list_images` | Tool returns without error and the plugin receives command `list_images`. With real GIMP the result carries the live GIMP state described in the docstring. |
| Raise a specific image to the front / make it active in GIMP | `gimp_mcp_server.py:2554` `set_active_image` | MCP tool `set_active_image` | Tool returns without error and the plugin receives command `set_active_image`. With real GIMP the result carries the live GIMP state described in the docstring. |
| Get metadata about the current open image in GIMP without the bitmap data | `gimp_mcp_server.py:247` `get_image_metadata` | MCP tool `get_image_metadata` | Tool returns without error and the plugin receives command `get_image_metadata`. With real GIMP the result carries the live GIMP state described in the docstring. |
| Get the current open image in GIMP as an Image object with optional scaling and region selection | `gimp_mcp_server.py:181` `get_image_bitmap` | MCP tool `get_image_bitmap` | Tool returns without error and the plugin receives command `get_image_bitmap`. With real GIMP the result carries the live GIMP state described in the docstring. |
| Return a live visual snapshot of the current image state — no file save needed | `gimp_mcp_server.py:311` `get_state_snapshot` | MCP tool `get_state_snapshot` | Tool returns without error and the plugin receives command `get_image_bitmap`. With real GIMP the result carries the live GIMP state described in the docstring. |

### File operations

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Create a new blank canvas in GIMP and open it in a display window | `gimp_mcp_server.py:130` `new_canvas` | MCP tool `new_canvas` | Plugin receives `new_canvas`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Open an image file in GIMP and create a display window | `gimp_mcp_server.py:521` `open_image` | MCP tool `open_image` | Plugin receives `open_image`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Save the current image as a GIMP XCF file (preserves all layers and metadata) | `gimp_mcp_server.py:546` `save_xcf` | MCP tool `save_xcf` | Plugin receives `save_xcf`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Export the current image to a raster file (PNG, JPEG, WEBP, TIFF) | `gimp_mcp_server.py:569` `export_image` | MCP tool `export_image` | Plugin receives `export_image`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Export all open images (or a specific one) to a directory | `gimp_mcp_server.py:607` `batch_export` | MCP tool `batch_export` | Plugin receives `batch_export`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Close an image, optionally saving as XCF first | `gimp_mcp_server.py:2645` `close_image` | MCP tool `close_image` | Plugin receives `close_image`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Export an image as a complete icon set for Android or iOS | `gimp_mcp_server.py:2308` `export_icon_sizes` | MCP tool `export_icon_sizes` | Plugin receives `export_icon_sizes`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Export an image as both JPEG and PNG, choosing the smaller format | `gimp_mcp_server.py:2344` `export_web_optimized` | MCP tool `export_web_optimized` | Plugin receives `export_web_optimized`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Combine multiple frames into a sprite sheet PNG | `gimp_mcp_server.py:2460` `export_sprite_sheet` | MCP tool `export_sprite_sheet` | Plugin receives `export_sprite_sheet`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Export an image resized for multiple social media platforms | `gimp_mcp_server.py:2494` `export_social_media_kit` | MCP tool `export_social_media_kit` | Plugin receives `export_social_media_kit`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |
| Resize all open images to a common target size | `gimp_mcp_server.py:2429` `batch_resize` | MCP tool `batch_resize` | Plugin receives `batch_resize`. With real GIMP the file or image named in the arguments exists afterwards (`ls` the output path or `list_images`). |

### Tonal and colour adjustments

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Automatically stretch the tonal range of an image (auto levels / auto stretch contrast) | `gimp_mcp_server.py:653` `auto_levels` | MCP tool `auto_levels` | Plugin receives `auto_levels`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Adjust tonal curves for a layer | `gimp_mcp_server.py:674` `adjust_curves` | MCP tool `adjust_curves` | Plugin receives `adjust_curves`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Adjust brightness and contrast of a layer | `gimp_mcp_server.py:711` `adjust_brightness_contrast` | MCP tool `adjust_brightness_contrast` | Plugin receives `adjust_brightness_contrast`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Adjust hue, saturation, and lightness of a layer | `gimp_mcp_server.py:745` `adjust_hue_saturation` | MCP tool `adjust_hue_saturation` | Plugin receives `adjust_hue_saturation`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Adjust color balance (shadows / midtones / highlights) of a layer | `gimp_mcp_server.py:785` `adjust_color_balance` | MCP tool `adjust_color_balance` | Plugin receives `adjust_color_balance`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Sharpen a layer using unsharp mask | `gimp_mcp_server.py:825` `sharpen` | MCP tool `sharpen` | Plugin receives `sharpen`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Apply Gaussian blur to a layer | `gimp_mcp_server.py:862` `blur` | MCP tool `blur` | Plugin receives `blur`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Reduce noise in a layer using GEGL noise-reduction | `gimp_mcp_server.py:896` `denoise` | MCP tool `denoise` | Plugin receives `denoise`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Convert a layer to grayscale (desaturate) | `gimp_mcp_server.py:927` `desaturate` | MCP tool `desaturate` | Plugin receives `desaturate`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Invert all colors in a layer (create a negative) | `gimp_mcp_server.py:958` `invert_colors` | MCP tool `invert_colors` | Plugin receives `invert_colors`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |
| Convert an image to a different color mode | `gimp_mcp_server.py:2616` `convert_color_mode` | MCP tool `convert_color_mode` | Plugin receives `convert_color_mode`. With real GIMP `get_pixel_color` or `get_histogram` before and after differ. |

### Geometry

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Scale an image to exact pixel dimensions | `gimp_mcp_server.py:990` `scale_image` | MCP tool `scale_image` | Plugin receives `scale_image`. With real GIMP `get_image_metadata` reports the new dimensions. |
| Scale an image to fit within a bounding box, preserving aspect ratio | `gimp_mcp_server.py:1024` `scale_to_fit` | MCP tool `scale_to_fit` | Plugin receives `scale_to_fit`. With real GIMP `get_image_metadata` reports the new dimensions. |
| Crop the image canvas to the current selection bounds | `gimp_mcp_server.py:1058` `crop_to_selection` | MCP tool `crop_to_selection` | Plugin receives `crop_to_selection`. With real GIMP `get_image_metadata` reports the new dimensions. |
| Crop the image canvas to an explicit rectangle | `gimp_mcp_server.py:1086` `crop_to_rect` | MCP tool `crop_to_rect` | Plugin receives `crop_to_rect`. With real GIMP `get_image_metadata` reports the new dimensions. |
| Rotate the entire image | `gimp_mcp_server.py:1121` `rotate_image` | MCP tool `rotate_image` | Plugin receives `rotate_image`. With real GIMP `get_image_metadata` reports the new dimensions. |
| Flip the entire image horizontally or vertically | `gimp_mcp_server.py:1150` `flip_image` | MCP tool `flip_image` | Plugin receives `flip_image`. With real GIMP `get_image_metadata` reports the new dimensions. |
| Resize the image canvas without scaling the content | `gimp_mcp_server.py:1178` `resize_canvas` | MCP tool `resize_canvas` | Plugin receives `resize_canvas`. With real GIMP `get_image_metadata` reports the new dimensions. |

### Selections

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Create a rectangular selection | `gimp_mcp_server.py:1219` `select_rectangle` | MCP tool `select_rectangle` | Plugin receives `select_rectangle`. With real GIMP `get_selection_bounds` reflects the change. |
| Create an elliptical selection | `gimp_mcp_server.py:1255` `select_ellipse` | MCP tool `select_ellipse` | Plugin receives `select_ellipse`. With real GIMP `get_selection_bounds` reflects the change. |
| Select regions by color similarity | `gimp_mcp_server.py:1291` `select_by_color` | MCP tool `select_by_color` | Plugin receives `select_by_color`. With real GIMP `get_selection_bounds` reflects the change. |
| Select the entire image canvas | `gimp_mcp_server.py:1328` `select_all` | MCP tool `select_all` | Plugin receives `select_all`. With real GIMP `get_selection_bounds` reflects the change. |
| Remove / deselect all selections | `gimp_mcp_server.py:1348` `select_none` | MCP tool `select_none` | Plugin receives `select_none`. With real GIMP `get_selection_bounds` reflects the change. |
| Invert the current selection (select what is not selected) | `gimp_mcp_server.py:1368` `invert_selection` | MCP tool `invert_selection` | Plugin receives `invert_selection`. With real GIMP `get_selection_bounds` reflects the change. |
| Grow, shrink, feather, border, or sharpen the current selection | `gimp_mcp_server.py:1388` `modify_selection` | MCP tool `modify_selection` | Plugin receives `modify_selection`. With real GIMP `get_selection_bounds` reflects the change. |
| Get the bounding rectangle of the current selection | `gimp_mcp_server.py:2672` `get_selection_bounds` | MCP tool `get_selection_bounds` | Plugin receives `get_selection_bounds`. With real GIMP `get_selection_bounds` reflects the change. |

### Layers

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Create and insert a new layer into an image | `gimp_mcp_server.py:1423` `create_layer` | MCP tool `create_layer` | Plugin receives `create_layer`. With real GIMP `list_layers` shows the change. |
| Duplicate a layer and insert the copy above it | `gimp_mcp_server.py:1463` `duplicate_layer` | MCP tool `duplicate_layer` | Plugin receives `duplicate_layer`. With real GIMP `list_layers` shows the change. |
| Delete a layer from an image | `gimp_mcp_server.py:1491` `delete_layer` | MCP tool `delete_layer` | Plugin receives `delete_layer`. With real GIMP `list_layers` shows the change. |
| Rename a layer | `gimp_mcp_server.py:1524` `rename_layer` | MCP tool `rename_layer` | Plugin receives `rename_layer`. With real GIMP `list_layers` shows the change. |
| Set properties on an existing layer | `gimp_mcp_server.py:1558` `set_layer_properties` | MCP tool `set_layer_properties` | Plugin receives `set_layer_properties`. With real GIMP `list_layers` shows the change. |
| Move a layer to a new stack position | `gimp_mcp_server.py:1594` `reorder_layer` | MCP tool `reorder_layer` | Plugin receives `reorder_layer`. With real GIMP `list_layers` shows the change. |
| Flatten all layers into a single background layer | `gimp_mcp_server.py:1625` `flatten_image` | MCP tool `flatten_image` | Plugin receives `flatten_image`. With real GIMP `list_layers` shows the change. |
| Merge all visible layers into a single layer | `gimp_mcp_server.py:1645` `merge_visible_layers` | MCP tool `merge_visible_layers` | Plugin receives `merge_visible_layers`. With real GIMP `list_layers` shows the change. |
| List all layers in an image with their properties | `gimp_mcp_server.py:1665` `list_layers` | MCP tool `list_layers` | Plugin receives `list_layers`. With real GIMP `list_layers` shows the change. |

### Drawing and text

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Fill an entire layer with a solid color | `gimp_mcp_server.py:1689` `fill_layer` | MCP tool `fill_layer` | Plugin receives `fill_layer`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Fill the current selection with a color or fill type | `gimp_mcp_server.py:1718` `fill_selection` | MCP tool `fill_selection` | Plugin receives `fill_selection`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Set the GIMP foreground and/or background color | `gimp_mcp_server.py:1750` `set_colors` | MCP tool `set_colors` | Plugin receives `set_colors`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Draw a straight line on a layer | `gimp_mcp_server.py:1777` `draw_line` | MCP tool `draw_line` | Plugin receives `draw_line`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Draw a rectangle outline (stroke only) on a layer | `gimp_mcp_server.py:1818` `draw_rectangle` | MCP tool `draw_rectangle` | Plugin receives `draw_rectangle`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Draw an ellipse outline (stroke only) on a layer | `gimp_mcp_server.py:1857` `draw_ellipse` | MCP tool `draw_ellipse` | Plugin receives `draw_ellipse`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Fill a rectangular region with a solid color | `gimp_mcp_server.py:1896` `fill_rectangle` | MCP tool `fill_rectangle` | Plugin receives `fill_rectangle`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Fill an elliptical region with a solid color | `gimp_mcp_server.py:1932` `fill_ellipse` | MCP tool `fill_ellipse` | Plugin receives `fill_ellipse`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Fill a layer or selection with a gradient | `gimp_mcp_server.py:1968` `gradient_fill` | MCP tool `gradient_fill` | Plugin receives `gradient_fill`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Add a text layer to an image | `gimp_mcp_server.py:2014` `add_text` | MCP tool `add_text` | Plugin receives `add_text`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Edit an existing text layer's content or formatting | `gimp_mcp_server.py:2052` `edit_text` | MCP tool `edit_text` | Plugin receives `edit_text`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| List available fonts installed in GIMP | `gimp_mcp_server.py:2089` `list_fonts` | MCP tool `list_fonts` | Plugin receives `list_fonts`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Get the color of a single pixel | `gimp_mcp_server.py:2692` `get_pixel_color` | MCP tool `get_pixel_color` | Plugin receives `get_pixel_color`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |
| Get histogram statistics for a channel of the active layer | `gimp_mcp_server.py:2722` `get_histogram` | MCP tool `get_histogram` | Plugin receives `get_histogram`. With real GIMP `get_pixel_color` at the drawn coordinates (or `list_layers` for text layers) shows the result. |

### Effects

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Apply a drop shadow effect to a layer | `gimp_mcp_server.py:2113` `apply_drop_shadow` | MCP tool `apply_drop_shadow` | Plugin receives `apply_drop_shadow`. With real GIMP `get_state_snapshot` before and after differ. |
| Apply Gaussian blur as a destructive filter operation | `gimp_mcp_server.py:2151` `apply_gaussian_blur` | MCP tool `apply_gaussian_blur` | Plugin receives `apply_gaussian_blur`. With real GIMP `get_state_snapshot` before and after differ. |
| Pixelate a layer using a mosaic/block effect | `gimp_mcp_server.py:2180` `apply_pixelate` | MCP tool `apply_pixelate` | Plugin receives `apply_pixelate`. With real GIMP `get_state_snapshot` before and after differ. |
| Apply an emboss (bas-relief) effect to a layer | `gimp_mcp_server.py:2209` `apply_emboss` | MCP tool `apply_emboss` | Plugin receives `apply_emboss`. With real GIMP `get_state_snapshot` before and after differ. |
| Apply a vignette darkening effect around the edges of a layer | `gimp_mcp_server.py:2243` `apply_vignette` | MCP tool `apply_vignette` | Plugin receives `apply_vignette`. With real GIMP `get_state_snapshot` before and after differ. |
| Add noise/grain to a layer | `gimp_mcp_server.py:2275` `apply_noise` | MCP tool `apply_noise` | Plugin receives `apply_noise`. With real GIMP `get_state_snapshot` before and after differ. |
| Warp / liquify a region of the image by pushing pixels in a direction | `gimp_mcp_server.py:2383` `warp_region` | MCP tool `warp_region` | Plugin receives `warp_region`. With real GIMP `get_state_snapshot` before and after differ. |

### History

| Feature | Where | How to reach it | How to check it works |
|---|---|---|---|
| Undo one or more operations on an image | `gimp_mcp_server.py:2574` `undo` | MCP tool `undo` | Plugin receives `undo`. With real GIMP `list_layers` or `get_pixel_color` returns to the earlier (undo) or later (redo) state. |
| Redo one or more previously undone operations on an image | `gimp_mcp_server.py:2595` `redo` | MCP tool `redo` | Plugin receives `redo`. With real GIMP `list_layers` or `get_pixel_color` returns to the earlier (undo) or later (redo) state. |

# Roku Channel Search Application

Efficient search and filter handler for Roku devices processing 5,000+ channels with case-insensitive search, debounced input handling, and optimized performance for constrained hardware.

## Features

- **Case-insensitive search** on channel title and category fields
- **Debounced input** to prevent excessive processing during typing
- **Performance optimized** for Roku device constraints (limited CPU and memory)

## Project Structure

- `source/Main.brs` - Application entry point
- `components/ChannelSearchScene.xml` - UI layout definition
- `components/ChannelSearchScene.brs` - Search logic and event handlers
- `resources/channels.json` - Channel dataset (5,000 channels)
- `manifest` - Roku application manifest

## Development Workflow

This project follows Gitflow workflow:
- Feature branches merge into `develop`
- `develop` merges into `master` for releases

## Performance Notes

The search algorithm uses linear search (O(n)) optimized for Roku devices:
- Pre-normalized strings reduce per-search overhead
- Single pass through channels checking both title and category
- Minimal object creation during search
- Timer reuse prevents garbage collection overhead


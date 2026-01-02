# Tech task: Efficient Search

## Context
We have a "Find Channel" feature that allows users to browse through a large catalog of content. As we expand to the Roku platform, we face significant hardware limitations, specifically regarding CPU performance and memory management. We need an efficient filtering logic that can handle thousands of items without causing UI latency.
## The Task
Your goal is to build a search and filter logic handler that processes a dataset of 5,000 channels.

## Requirements
1. **Search Logic:** Implement a case-insensitive search that filters by `title` and `category`.
2. **Debounce:** To prevent excessive processing during typing, implement a debounce mechanism.
3. **Performance:** Since this is intended for Roku devices, prioritize algorithmic efficiency. Please include notes explaining your choice of filtering method.
4. **Implementation:** You may use **BrightScript, JavaScript, or TypeScript**. We are interested in your logic and architectural approach rather than specific syntax.

## Dataset 
Please use the provided dataset `channels.json`.

## Submission Instructions
1. Create a public GitHub repository for your solution.
2. Please maintain a consistent and descriptive commit history. We want to see your development process and how the solution evolved from start to finish.
3. Once the task is complete, share the repository link with the HR.
4. You will be able to discuss your solution during the next interview scheduled after we review your code.

We look forward to seeing your approach and your development process!


# Faculty Collaboration Dashboard

### Project Overview
The Faculty Collaboration Dashboard is designed to present data about faculty research collaborations in a user-friendly, interactive format. It provides tools for exploring faculty networks, identifying interdisciplinary research opportunities, and analyzing collaboration patterns to enhance productivity and job satisfaction.

### Project Objectives
- **Foster Interdisciplinary Research**: Identify potential collaborations across departments or research areas.
- **Identify Funding Opportunities**: Analyze networks to discover external collaborators for joint grant applications.
- **Enhance Productivity**: Reveal collaboration patterns that lead to higher academic success.
- **Support Social Networks**: Foster faculty retention by visualizing social support structures.

### Tools and Technologies
- **R Studio**: The core development environment used.
- **R Packages**:
  - `igraph`: Create and analyze network graphs.
  - `tidyverse`: Data manipulation and visualization, especially `dplyr` for data wrangling and `ggplot2` for plotting.
  - `visNetwork`: Create interactive network visualizations for web applications.
  - `shiny`: Build an interactive web application for displaying network data.
  - `shinydashboard`: A framework for organizing dashboard layouts.
  - `networktools`: For advanced network analysis, identifying communities, central nodes, etc.

### Data Sources
Data was collected from VSU faculty members who applied for grants in 2021. The dataset includes:
- **title**: Research project title.
- **purpose**: Project purpose.
- **pi**: Principal investigator.
- **agency**: Funding agency.
- **team**: Faculty team members.
- **collaboration info**: Collaboration types and external collaborators.
- **faculty info**: Faculty members and departments involved.

### App Features
- **Interactive Network Graph**: Explore faculty collaboration networks.
- **Node Attributes**: Degree, betweenness, closeness, and eigenvector centrality for each faculty node.
- **Graph Customization**: Nodes colored by community, sized by collaboration intensity.
- **Edge Thickness**: Represents the strength of collaboration between two nodes.

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/faculty-collaboration-dashboard.git
   ```
2. Install required R packages:
   ```R
   install.packages(c("shiny", "shinydashboard", "visNetwork", "igraph", "tidyverse", "networktools"))
   ```
3. Run the Shiny App:
   ```R
   shiny::runApp('path_to_your_shiny_app')
   ```

### Usage
The dashboard enables users to explore faculty collaboration patterns at Virginia State University. Use the interactive graph to identify key nodes, communities, and collaboration paths.

### Future Improvements
- Add search functionality for specific faculty members.
- Incorporate more advanced graph metrics and filters.
- Visualize funding data linked to collaborations.

### Contributing
Feel free to fork this project, submit issues, and make pull requests to improve the dashboard. Contributions are welcome!

### Authors and Acknowledgements
- **Raven Mott**: Developer, Data Science for the Public Good (DSPG) Program.
- **Dr. M. Omar Faison**: Associate Vice Provost, Research & Economic Development.
- **Dr. Samuel J. West**: Assistant Professor.
- **Manuela Deigh**: Contributor.


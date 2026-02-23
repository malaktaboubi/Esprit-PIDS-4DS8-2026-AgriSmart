import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.patches import Patch
import numpy as np

def generate_zone_map(ndvi_array, cluster_labels, output_path="field_zoning_map.png"):
    # Convert labels to numpy
    if isinstance(cluster_labels, list):
        cluster_labels = np.array(cluster_labels)
    
    # Standardize Color Palette (Red -> Orange -> Yellow -> Light Green -> Dark Green)
    # This represents: Low -> High productivity
    earth_colors = ['#e74c3c', '#e67e22', '#f1c40f', '#9bdf46', '#27ae60']
    
    # Reconstruct 2D Map
    map_data = np.full(ndvi_array.shape, np.nan)
    mask = ~np.isnan(ndvi_array)
    map_data[mask] = cluster_labels

    unique_zones = np.unique(cluster_labels).astype(int)
    n_clusters = len(unique_zones)
    
    # FIX: Use ListedColormap for sharp, discrete management zones
    cmap = mcolors.ListedColormap(earth_colors[:n_clusters])

    plt.figure(figsize=(14, 10))
    ax = plt.gca()
    
    # FIX: interpolation='nearest' prevents the "blurred" look
    im = ax.imshow(map_data, cmap=cmap, interpolation='nearest')

    # Legend and Statistics setup
    zone_descriptions = ['Low Vegetation', 'Moderate', 'Good', 'High', 'Excellent']
    legend_elements = []
    stats_text = "Zone Statistics:\n"
    
    total_pixels = len(cluster_labels)
    counts = np.bincount(cluster_labels.astype(int), minlength=n_clusters)

    for i in unique_zones:
        percentage = (counts[i] / total_pixels) * 100
        stats_text += f"Zone {i}: {percentage:.1f}%\n"
        
        legend_elements.append(Patch(
            facecolor=earth_colors[i], 
            label=f'Zone {i}: {zone_descriptions[i]}'
        ))

    # Add Info Boxes
    plt.text(0.02, 0.98, stats_text, transform=ax.transAxes, fontsize=11,
             verticalalignment='top', bbox=dict(facecolor='white', alpha=0.8))
    
    ax.legend(handles=legend_elements, loc='lower left', fontsize=10)

    plt.title('Field Management Zones - NDVI Clustering', fontsize=18, weight='bold', pad=20)
    plt.axis('off')
    
    # Scale Bar logic (Same as yours, but ensures white background)
    plt.savefig(output_path, bbox_inches='tight', dpi=300, facecolor='white')
    plt.close()

    return output_path
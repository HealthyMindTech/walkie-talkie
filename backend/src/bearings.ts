type Coordinate = {
    latitude: number;
    longitude: number;
    timestamp: string;
};

function calculateBearing(startLat: number, startLng: number, destLat: number, destLng: number): number {
    // Convert degrees to radians
    const startLatRad = startLat * Math.PI / 180;
    const startLngRad = startLng * Math.PI / 180;
    const destLatRad = destLat * Math.PI / 180;
    const destLngRad = destLng * Math.PI / 180;

    const y = Math.sin(destLngRad - startLngRad) * Math.cos(destLatRad);
    const x = Math.cos(startLatRad) * Math.sin(destLatRad) -
        Math.sin(startLatRad) * Math.cos(destLatRad) * Math.cos(destLngRad - startLngRad);

    return (Math.atan2(y, x) * 180 / Math.PI + 360) % 360;
}


function averageBearing(coordinates: Coordinate[]): number {
    let totalBearing = 0;
    let count = 0;

    for (let i = 0; i < coordinates.length - 1; i++) {
        totalBearing += calculateBearing(
            coordinates[i].latitude, coordinates[i].longitude,
            coordinates[i + 1].latitude, coordinates[i + 1].longitude
        );
        count++;
    }

    return totalBearing / count;
}

function analyzeMovement(coordinates: Coordinate[]): string {
    if (coordinates.length < 3) {
        return "Insufficient data";
    }

    // Assuming coordinates are sorted by createdAt
    const bearing1 = calculateBearing(
        coordinates[0].latitude, coordinates[0].longitude,
        coordinates[1].latitude, coordinates[1].longitude
    );
    const bearing2 = calculateBearing(
        coordinates[1].latitude, coordinates[1].longitude,
        coordinates[2].latitude, coordinates[2].longitude
    );

    const bearingChange = bearing2 - bearing1;

    if (bearingChange > 45 && bearingChange <= 180) {
        return "Turned Right";
    } else if (bearingChange > -180 && bearingChange < 0) {
        return "Turned Left";
    } else {
        return "Moving Forward";
    }
}

export { analyzeMovement, averageBearing };

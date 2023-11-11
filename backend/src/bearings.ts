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


const distance = (lat1: number, lon1: number, lat2: number, lon2: number): number => {
    if ((lat1 == lat2) && (lon1 == lon2)) {
        return 0;
    }
    else {
        var radlat1 = Math.PI * lat1 / 180;
        var radlat2 = Math.PI * lat2 / 180;
        var theta = lon1 - lon2;
        var radtheta = Math.PI * theta / 180;
        var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
        if (dist > 1) {
            dist = 1;
        }
        dist = Math.acos(dist);
        dist = dist * 180 / Math.PI;
        dist = dist * 60 * 1.1515;
        dist = dist * 1609.344;
        return dist;
    }
}
export { calculateBearing, distance };

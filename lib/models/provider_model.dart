class ProviderModel {
  final String id;
  final String name;
  final String serviceType; // 'electrician', 'plumber', 'delivery'
  final double rating;
  final int jobsDone;
  final int experience;
  final double startingPrice;
  final String bio;
  final double distanceKm;
  final bool isAvailable;

  ProviderModel({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.rating,
    required this.jobsDone,
    required this.experience,
    required this.startingPrice,
    required this.bio,
    required this.distanceKm,
    required this.isAvailable,
  });

  String get serviceLabel {
    switch (serviceType) {
      case 'electrician': return 'Electrician';
      case 'plumber':     return 'Plumber';
      case 'delivery':    return 'Delivery';
      default:            return serviceType;
    }
  }
}

// Sample data
final List<ProviderModel> sampleProviders = [
  ProviderModel(id:'1', name:'Mohamed Ali',    serviceType:'electrician', rating:4.8, jobsDone:120, experience:3, startingPrice:150, bio:'Professional electrician with 3+ years experience.', distanceKm:1.2, isAvailable:true),
  ProviderModel(id:'2', name:'Tarek Hassan',   serviceType:'electrician', rating:4.6, jobsDone:85,  experience:2, startingPrice:120, bio:'Residential & commercial electrical work.', distanceKm:2.1, isAvailable:true),
  ProviderModel(id:'3', name:'Khaled Nour',    serviceType:'plumber',     rating:4.7, jobsDone:98,  experience:4, startingPrice:130, bio:'Expert plumber for all repairs and installations.', distanceKm:0.8, isAvailable:true),
  ProviderModel(id:'4', name:'Ahmed Gamal',    serviceType:'plumber',     rating:4.4, jobsDone:60,  experience:2, startingPrice:110, bio:'Fast and reliable plumbing services.', distanceKm:1.9, isAvailable:false),
  ProviderModel(id:'5', name:'Fast Delivery',  serviceType:'delivery',    rating:4.9, jobsDone:300, experience:1, startingPrice:30,  bio:'Quick delivery anywhere in Cairo.', distanceKm:0.5, isAvailable:true),
  ProviderModel(id:'6', name:'QuickRun',       serviceType:'delivery',    rating:4.7, jobsDone:210, experience:2, startingPrice:25,  bio:'Express delivery, 24/7.', distanceKm:1.1, isAvailable:false),
];

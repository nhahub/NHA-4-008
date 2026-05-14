import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  String? _collectionName;
  String? _docId;
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _profileImageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }
  
  Future<void> _loadProviderData() async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception("User not logged in");
      
      _docId = user.uid;
      
      const collections = ['electricians', 'plumbers', 'delivery'];
      DocumentSnapshot? foundDoc;
      String? foundCol;
      
      for (final col in collections) {
        final doc = await FirebaseFirestore.instance.collection(col).doc(user.uid).get();
        if (doc.exists) {
          foundDoc = doc;
          foundCol = col;
          break;
        }
      }
      
      if (foundDoc != null && foundCol != null) {
        _collectionName = foundCol;
        final data = foundDoc.data() as Map<String, dynamic>;
        
        _fullNameController.text = data['fullName'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _addressController.text = data['address'] ?? '';
        _startingPriceController.text = (data['startingPrice'] ?? '').toString();
        _profileImageController.text = data['profileImageUrl'] ?? '';
      } else {
        throw Exception("Provider profile not found.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_collectionName == null || _docId == null) return;
    
    setState(() => _isSaving = true);
    
    try {
      final startingPrice = double.tryParse(_startingPriceController.text) ?? 0.0;
      
      await FirebaseFirestore.instance.collection(_collectionName!).doc(_docId).update({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'address': _addressController.text.trim(),
        'startingPrice': startingPrice,
        'profileImageUrl': _profileImageController.text.trim(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _startingPriceController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _profileImageController.text.isNotEmpty
                ? NetworkImage(_profileImageController.text)
                : null,
            child: _profileImageController.text.isEmpty
                ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                : null,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _profileImageController,
          label: "Profile Image URL",
          icon: Icons.image_outlined,
          onChanged: (val) {
            setState(() {}); 
          }
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 24),
                  
                  _buildTextField(
                    controller: _fullNameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                    validator: (v) => v!.trim().isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.trim().isEmpty ? "Enter your phone number" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _addressController,
                    label: "Address",
                    icon: Icons.location_on_outlined,
                    validator: (v) => v!.trim().isEmpty ? "Enter your address" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _startingPriceController,
                    label: "Starting Price",
                    icon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v!.trim().isEmpty ? "Enter starting price" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _bioController,
                    label: "Bio",
                    icon: Icons.info_outline,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
        ),
    );
  }
}

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
// EXTRA BEGIN
typedef struct DartCObject *WireSyncRust2DartDco;
typedef struct WireSyncRust2DartSse {
  uint8_t *ptr;
  int32_t len;
} WireSyncRust2DartSse;

typedef int64_t DartPort;
typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);
void store_dart_post_cobject(DartPostCObjectFnType ptr);
// EXTRA END
typedef struct _Dart_Handle* Dart_Handle;

typedef struct wire_cst_list_prim_u_8_strict {
  uint8_t *ptr;
  int32_t len;
} wire_cst_list_prim_u_8_strict;

typedef struct wire_cst_list_prim_u_8_loose {
  uint8_t *ptr;
  int32_t len;
} wire_cst_list_prim_u_8_loose;

typedef struct wire_cst_list_String {
  struct wire_cst_list_prim_u_8_strict **ptr;
  int32_t len;
} wire_cst_list_String;

typedef struct wire_cst_file_part_list_item {
  struct wire_cst_list_prim_u_8_strict *part_id;
  int32_t sequence;
  bool extern_storage;
} wire_cst_file_part_list_item;

typedef struct wire_cst_list_file_part_list_item {
  struct wire_cst_file_part_list_item *ptr;
  int32_t len;
} wire_cst_list_file_part_list_item;

typedef struct wire_cst_group_children_list {
  struct wire_cst_list_prim_u_8_strict *group_id;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *parent;
} wire_cst_group_children_list;

typedef struct wire_cst_list_group_children_list {
  struct wire_cst_group_children_list *ptr;
  int32_t len;
} wire_cst_list_group_children_list;

typedef struct wire_cst_group_invite_req_list {
  struct wire_cst_list_prim_u_8_strict *group_id;
  struct wire_cst_list_prim_u_8_strict *time;
} wire_cst_group_invite_req_list;

typedef struct wire_cst_list_group_invite_req_list {
  struct wire_cst_group_invite_req_list *ptr;
  int32_t len;
} wire_cst_list_group_invite_req_list;

typedef struct wire_cst_group_join_req_list {
  struct wire_cst_list_prim_u_8_strict *user_id;
  struct wire_cst_list_prim_u_8_strict *time;
  int32_t user_type;
} wire_cst_group_join_req_list;

typedef struct wire_cst_list_group_join_req_list {
  struct wire_cst_group_join_req_list *ptr;
  int32_t len;
} wire_cst_list_group_join_req_list;

typedef struct wire_cst_group_out_data_hmac_keys {
  struct wire_cst_list_prim_u_8_strict *group_key_id;
  struct wire_cst_list_prim_u_8_strict *key_data;
} wire_cst_group_out_data_hmac_keys;

typedef struct wire_cst_list_group_out_data_hmac_keys {
  struct wire_cst_group_out_data_hmac_keys *ptr;
  int32_t len;
} wire_cst_list_group_out_data_hmac_keys;

typedef struct wire_cst_group_out_data_keys {
  struct wire_cst_list_prim_u_8_strict *private_key_id;
  struct wire_cst_list_prim_u_8_strict *key_data;
  struct wire_cst_list_prim_u_8_strict *signed_by_user_id;
  struct wire_cst_list_prim_u_8_strict *signed_by_user_sign_key_id;
} wire_cst_group_out_data_keys;

typedef struct wire_cst_list_group_out_data_keys {
  struct wire_cst_group_out_data_keys *ptr;
  int32_t len;
} wire_cst_list_group_out_data_keys;

typedef struct wire_cst_group_out_data_sortable_keys {
  struct wire_cst_list_prim_u_8_strict *group_key_id;
  struct wire_cst_list_prim_u_8_strict *key_data;
} wire_cst_group_out_data_sortable_keys;

typedef struct wire_cst_list_group_out_data_sortable_keys {
  struct wire_cst_group_out_data_sortable_keys *ptr;
  int32_t len;
} wire_cst_list_group_out_data_sortable_keys;

typedef struct wire_cst_group_user_list_item {
  struct wire_cst_list_prim_u_8_strict *user_id;
  int32_t rank;
  struct wire_cst_list_prim_u_8_strict *joined_time;
  int32_t user_type;
} wire_cst_group_user_list_item;

typedef struct wire_cst_list_group_user_list_item {
  struct wire_cst_group_user_list_item *ptr;
  int32_t len;
} wire_cst_list_group_user_list_item;

typedef struct wire_cst_key_rotation_get_out {
  struct wire_cst_list_prim_u_8_strict *pre_group_key_id;
  struct wire_cst_list_prim_u_8_strict *new_group_key_id;
  struct wire_cst_list_prim_u_8_strict *encrypted_eph_key_key_id;
  struct wire_cst_list_prim_u_8_strict *server_output;
} wire_cst_key_rotation_get_out;

typedef struct wire_cst_list_key_rotation_get_out {
  struct wire_cst_key_rotation_get_out *ptr;
  int32_t len;
} wire_cst_list_key_rotation_get_out;

typedef struct wire_cst_list_groups {
  struct wire_cst_list_prim_u_8_strict *group_id;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *joined_time;
  int32_t rank;
  struct wire_cst_list_prim_u_8_strict *parent;
} wire_cst_list_groups;

typedef struct wire_cst_list_list_groups {
  struct wire_cst_list_groups *ptr;
  int32_t len;
} wire_cst_list_list_groups;

typedef struct wire_cst_user_device_list {
  struct wire_cst_list_prim_u_8_strict *device_id;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *device_identifier;
} wire_cst_user_device_list;

typedef struct wire_cst_list_user_device_list {
  struct wire_cst_user_device_list *ptr;
  int32_t len;
} wire_cst_list_user_device_list;

typedef struct wire_cst_user_key_data {
  struct wire_cst_list_prim_u_8_strict *private_key;
  struct wire_cst_list_prim_u_8_strict *public_key;
  struct wire_cst_list_prim_u_8_strict *group_key;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *group_key_id;
  struct wire_cst_list_prim_u_8_strict *sign_key;
  struct wire_cst_list_prim_u_8_strict *verify_key;
  struct wire_cst_list_prim_u_8_strict *exported_public_key;
  struct wire_cst_list_prim_u_8_strict *exported_public_key_sig_key_id;
  struct wire_cst_list_prim_u_8_strict *exported_verify_key;
} wire_cst_user_key_data;

typedef struct wire_cst_list_user_key_data {
  struct wire_cst_user_key_data *ptr;
  int32_t len;
} wire_cst_list_user_key_data;

typedef struct wire_cst_claims {
  struct wire_cst_list_prim_u_8_strict *aud;
  struct wire_cst_list_prim_u_8_strict *sub;
  uintptr_t exp;
  uintptr_t iat;
  bool fresh;
} wire_cst_claims;

typedef struct wire_cst_crypto_raw_output {
  struct wire_cst_list_prim_u_8_strict *head;
  struct wire_cst_list_prim_u_8_strict *data;
} wire_cst_crypto_raw_output;

typedef struct wire_cst_device_key_data {
  struct wire_cst_list_prim_u_8_strict *private_key;
  struct wire_cst_list_prim_u_8_strict *public_key;
  struct wire_cst_list_prim_u_8_strict *sign_key;
  struct wire_cst_list_prim_u_8_strict *verify_key;
  struct wire_cst_list_prim_u_8_strict *exported_public_key;
  struct wire_cst_list_prim_u_8_strict *exported_verify_key;
} wire_cst_device_key_data;

typedef struct wire_cst_encrypted_head {
  struct wire_cst_list_prim_u_8_strict *id;
  struct wire_cst_list_prim_u_8_strict *sign_id;
  struct wire_cst_list_prim_u_8_strict *sign_alg;
} wire_cst_encrypted_head;

typedef struct wire_cst_file_data {
  struct wire_cst_list_prim_u_8_strict *file_id;
  struct wire_cst_list_prim_u_8_strict *master_key_id;
  struct wire_cst_list_prim_u_8_strict *owner;
  struct wire_cst_list_prim_u_8_strict *belongs_to;
  int32_t belongs_to_type;
  struct wire_cst_list_prim_u_8_strict *encrypted_key;
  struct wire_cst_list_prim_u_8_strict *encrypted_key_alg;
  struct wire_cst_list_prim_u_8_strict *encrypted_file_name;
  struct wire_cst_list_file_part_list_item *part_list;
} wire_cst_file_data;

typedef struct wire_cst_file_done_register {
  struct wire_cst_list_prim_u_8_strict *file_id;
  struct wire_cst_list_prim_u_8_strict *session_id;
} wire_cst_file_done_register;

typedef struct wire_cst_file_download_result {
  struct wire_cst_list_prim_u_8_strict *next_file_key;
  struct wire_cst_list_prim_u_8_strict *file;
} wire_cst_file_download_result;

typedef struct wire_cst_file_prepare_register {
  struct wire_cst_list_prim_u_8_strict *encrypted_file_name;
  struct wire_cst_list_prim_u_8_strict *server_input;
} wire_cst_file_prepare_register;

typedef struct wire_cst_file_register_output {
  struct wire_cst_list_prim_u_8_strict *file_id;
  struct wire_cst_list_prim_u_8_strict *session_id;
  struct wire_cst_list_prim_u_8_strict *encrypted_file_name;
} wire_cst_file_register_output;

typedef struct wire_cst_generated_register_data {
  struct wire_cst_list_prim_u_8_strict *identifier;
  struct wire_cst_list_prim_u_8_strict *password;
} wire_cst_generated_register_data;

typedef struct wire_cst_group_data_check_update_server_output {
  bool key_update;
  int32_t rank;
} wire_cst_group_data_check_update_server_output;

typedef struct wire_cst_group_key_data {
  struct wire_cst_list_prim_u_8_strict *private_group_key;
  struct wire_cst_list_prim_u_8_strict *public_group_key;
  struct wire_cst_list_prim_u_8_strict *exported_public_key;
  struct wire_cst_list_prim_u_8_strict *group_key;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *group_key_id;
} wire_cst_group_key_data;

typedef struct wire_cst_group_out_data {
  struct wire_cst_list_prim_u_8_strict *group_id;
  struct wire_cst_list_prim_u_8_strict *parent_group_id;
  int32_t rank;
  bool key_update;
  struct wire_cst_list_prim_u_8_strict *created_time;
  struct wire_cst_list_prim_u_8_strict *joined_time;
  struct wire_cst_list_group_out_data_keys *keys;
  struct wire_cst_list_group_out_data_hmac_keys *hmac_keys;
  struct wire_cst_list_group_out_data_sortable_keys *sortable_keys;
  struct wire_cst_list_prim_u_8_strict *access_by_group_as_member;
  struct wire_cst_list_prim_u_8_strict *access_by_parent_group;
  bool is_connected_group;
} wire_cst_group_out_data;

typedef struct wire_cst_group_public_key_data {
  struct wire_cst_list_prim_u_8_strict *public_key;
  struct wire_cst_list_prim_u_8_strict *public_key_id;
} wire_cst_group_public_key_data;

typedef struct wire_cst_key_rotation_input {
  struct wire_cst_list_prim_u_8_strict *error;
  struct wire_cst_list_prim_u_8_strict *encrypted_ephemeral_key_by_group_key_and_public_key;
  struct wire_cst_list_prim_u_8_strict *encrypted_group_key_by_ephemeral;
  struct wire_cst_list_prim_u_8_strict *ephemeral_alg;
  struct wire_cst_list_prim_u_8_strict *encrypted_eph_key_key_id;
  struct wire_cst_list_prim_u_8_strict *previous_group_key_id;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *new_group_key_id;
} wire_cst_key_rotation_input;

typedef struct wire_cst_non_registered_key_output {
  struct wire_cst_list_prim_u_8_strict *key;
  struct wire_cst_list_prim_u_8_strict *encrypted_key;
} wire_cst_non_registered_key_output;

typedef struct wire_cst_otp_recovery_keys_output {
  struct wire_cst_list_String *keys;
} wire_cst_otp_recovery_keys_output;

typedef struct wire_cst_otp_register {
  struct wire_cst_list_prim_u_8_strict *secret;
  struct wire_cst_list_prim_u_8_strict *alg;
  struct wire_cst_list_String *recover;
} wire_cst_otp_register;

typedef struct wire_cst_otp_register_url {
  struct wire_cst_list_prim_u_8_strict *url;
  struct wire_cst_list_String *recover;
} wire_cst_otp_register_url;

typedef struct wire_cst_pre_register_device_data {
  struct wire_cst_list_prim_u_8_strict *input;
  struct wire_cst_list_prim_u_8_strict *exported_public_key;
} wire_cst_pre_register_device_data;

typedef struct wire_cst_register_device_data {
  struct wire_cst_list_prim_u_8_strict *session_id;
  struct wire_cst_list_prim_u_8_strict *exported_public_key;
} wire_cst_register_device_data;

typedef struct wire_cst_searchable_create_output {
  struct wire_cst_list_String *hashes;
  struct wire_cst_list_prim_u_8_strict *alg;
  struct wire_cst_list_prim_u_8_strict *key_id;
} wire_cst_searchable_create_output;

typedef struct wire_cst_sortable_encrypt_output {
  uint64_t number;
  struct wire_cst_list_prim_u_8_strict *alg;
  struct wire_cst_list_prim_u_8_strict *key_id;
} wire_cst_sortable_encrypt_output;

typedef struct wire_cst_user_data {
  struct wire_cst_list_prim_u_8_strict *jwt;
  struct wire_cst_list_prim_u_8_strict *user_id;
  struct wire_cst_list_prim_u_8_strict *device_id;
  struct wire_cst_list_prim_u_8_strict *refresh_token;
  struct wire_cst_device_key_data keys;
  struct wire_cst_list_user_key_data *user_keys;
  struct wire_cst_list_group_out_data_hmac_keys *hmac_keys;
} wire_cst_user_data;

typedef struct wire_cst_user_init_server_output {
  struct wire_cst_list_prim_u_8_strict *jwt;
  struct wire_cst_list_group_invite_req_list *invites;
} wire_cst_user_init_server_output;

typedef struct wire_cst_user_login_out {
  struct wire_cst_list_prim_u_8_strict *direct;
  struct wire_cst_list_prim_u_8_strict *master_key;
  struct wire_cst_list_prim_u_8_strict *auth_key;
} wire_cst_user_login_out;

typedef struct wire_cst_user_public_key_data {
  struct wire_cst_list_prim_u_8_strict *public_key;
  struct wire_cst_list_prim_u_8_strict *public_key_id;
  struct wire_cst_list_prim_u_8_strict *public_key_sig_key_id;
} wire_cst_user_public_key_data;

void frbgen_sentc_wire__crate__api__user__change_password(int64_t port_,
                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                          struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                          struct wire_cst_list_prim_u_8_strict *old_password,
                                                          struct wire_cst_list_prim_u_8_strict *new_password,
                                                          struct wire_cst_list_prim_u_8_strict *mfa_token,
                                                          bool *mfa_recovery);

void frbgen_sentc_wire__crate__api__user__check_user_identifier_available(int64_t port_,
                                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                          struct wire_cst_list_prim_u_8_strict *user_identifier);

void frbgen_sentc_wire__crate__api__crypto__create_searchable(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *key,
                                                              struct wire_cst_list_prim_u_8_strict *data,
                                                              bool full,
                                                              uint32_t *limit);

void frbgen_sentc_wire__crate__api__crypto__create_searchable_raw(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *key,
                                                                  struct wire_cst_list_prim_u_8_strict *data,
                                                                  bool full,
                                                                  uint32_t *limit);

WireSyncRust2DartDco frbgen_sentc_wire__crate__api__user__decode_jwt(struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_wire__crate__api__crypto__decrypt_asymmetric(int64_t port_,
                                                               struct wire_cst_list_prim_u_8_strict *private_key,
                                                               struct wire_cst_list_prim_u_8_loose *encrypted_data,
                                                               struct wire_cst_list_prim_u_8_strict *verify_key_data);

void frbgen_sentc_wire__crate__api__crypto__decrypt_raw_asymmetric(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *private_key,
                                                                   struct wire_cst_list_prim_u_8_loose *encrypted_data,
                                                                   struct wire_cst_list_prim_u_8_strict *head,
                                                                   struct wire_cst_list_prim_u_8_strict *verify_key_data);

void frbgen_sentc_wire__crate__api__crypto__decrypt_raw_symmetric(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *key,
                                                                  struct wire_cst_list_prim_u_8_loose *encrypted_data,
                                                                  struct wire_cst_list_prim_u_8_strict *head,
                                                                  struct wire_cst_list_prim_u_8_strict *verify_key_data);

void frbgen_sentc_wire__crate__api__crypto__decrypt_string_asymmetric(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *private_key,
                                                                      struct wire_cst_list_prim_u_8_strict *encrypted_data,
                                                                      struct wire_cst_list_prim_u_8_strict *verify_key_data);

void frbgen_sentc_wire__crate__api__crypto__decrypt_string_symmetric(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *key,
                                                                     struct wire_cst_list_prim_u_8_strict *encrypted_data,
                                                                     struct wire_cst_list_prim_u_8_strict *verify_key_data);

void frbgen_sentc_wire__crate__api__crypto__decrypt_sym_key(int64_t port_,
                                                            struct wire_cst_list_prim_u_8_strict *master_key,
                                                            struct wire_cst_list_prim_u_8_strict *encrypted_symmetric_key_info);

void frbgen_sentc_wire__crate__api__crypto__decrypt_sym_key_by_private_key(int64_t port_,
                                                                           struct wire_cst_list_prim_u_8_strict *private_key,
                                                                           struct wire_cst_list_prim_u_8_strict *encrypted_symmetric_key_info);

void frbgen_sentc_wire__crate__api__crypto__decrypt_symmetric(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *key,
                                                              struct wire_cst_list_prim_u_8_loose *encrypted_data,
                                                              struct wire_cst_list_prim_u_8_strict *verify_key_data);

void frbgen_sentc_wire__crate__api__user__delete_device(int64_t port_,
                                                        struct wire_cst_list_prim_u_8_strict *base_url,
                                                        struct wire_cst_list_prim_u_8_strict *auth_token,
                                                        struct wire_cst_list_prim_u_8_strict *fresh_jwt,
                                                        struct wire_cst_list_prim_u_8_strict *device_id);

void frbgen_sentc_wire__crate__api__user__delete_user(int64_t port_,
                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                      struct wire_cst_list_prim_u_8_strict *fresh_jwt);

void frbgen_sentc_wire__crate__api__crypto__deserialize_head_from_string(int64_t port_,
                                                                         struct wire_cst_list_prim_u_8_strict *head);

void frbgen_sentc_wire__crate__api__user__disable_otp(int64_t port_,
                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                      struct wire_cst_list_prim_u_8_strict *jwt);

WireSyncRust2DartDco frbgen_sentc_wire__crate__api__user__done_check_user_identifier_available(struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_wire__crate__api__crypto__done_fetch_sym_key(int64_t port_,
                                                               struct wire_cst_list_prim_u_8_strict *master_key,
                                                               struct wire_cst_list_prim_u_8_strict *server_out,
                                                               bool non_registered);

void frbgen_sentc_wire__crate__api__crypto__done_fetch_sym_key_by_private_key(int64_t port_,
                                                                              struct wire_cst_list_prim_u_8_strict *private_key,
                                                                              struct wire_cst_list_prim_u_8_strict *server_out,
                                                                              bool non_registered);

void frbgen_sentc_wire__crate__api__user__done_fetch_user_key(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *private_key,
                                                              struct wire_cst_list_prim_u_8_strict *server_output);

WireSyncRust2DartDco frbgen_sentc_wire__crate__api__user__done_register(struct wire_cst_list_prim_u_8_strict *server_output);

WireSyncRust2DartDco frbgen_sentc_wire__crate__api__user__done_register_device_start(struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_wire__crate__api__crypto__encrypt_asymmetric(int64_t port_,
                                                               struct wire_cst_list_prim_u_8_strict *reply_public_key_data,
                                                               struct wire_cst_list_prim_u_8_loose *data,
                                                               struct wire_cst_list_prim_u_8_strict *sign_key);

void frbgen_sentc_wire__crate__api__crypto__encrypt_raw_asymmetric(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *reply_public_key_data,
                                                                   struct wire_cst_list_prim_u_8_loose *data,
                                                                   struct wire_cst_list_prim_u_8_strict *sign_key);

void frbgen_sentc_wire__crate__api__crypto__encrypt_raw_symmetric(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *key,
                                                                  struct wire_cst_list_prim_u_8_loose *data,
                                                                  struct wire_cst_list_prim_u_8_strict *sign_key);

void frbgen_sentc_wire__crate__api__crypto__encrypt_string_asymmetric(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *reply_public_key_data,
                                                                      struct wire_cst_list_prim_u_8_strict *data,
                                                                      struct wire_cst_list_prim_u_8_strict *sign_key);

void frbgen_sentc_wire__crate__api__crypto__encrypt_string_symmetric(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *key,
                                                                     struct wire_cst_list_prim_u_8_strict *data,
                                                                     struct wire_cst_list_prim_u_8_strict *sign_key);

void frbgen_sentc_wire__crate__api__crypto__encrypt_symmetric(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *key,
                                                              struct wire_cst_list_prim_u_8_loose *data,
                                                              struct wire_cst_list_prim_u_8_strict *sign_key);

void frbgen_sentc_wire__crate__api__user__extract_user_data(int64_t port_,
                                                            struct wire_cst_list_prim_u_8_strict *data);

void frbgen_sentc_wire__crate__api__user__fetch_user_key(int64_t port_,
                                                         struct wire_cst_list_prim_u_8_strict *base_url,
                                                         struct wire_cst_list_prim_u_8_strict *auth_token,
                                                         struct wire_cst_list_prim_u_8_strict *jwt,
                                                         struct wire_cst_list_prim_u_8_strict *key_id,
                                                         struct wire_cst_list_prim_u_8_strict *private_key);

void frbgen_sentc_wire__crate__api__file__file_delete_file(int64_t port_,
                                                           struct wire_cst_list_prim_u_8_strict *base_url,
                                                           struct wire_cst_list_prim_u_8_strict *auth_token,
                                                           struct wire_cst_list_prim_u_8_strict *jwt,
                                                           struct wire_cst_list_prim_u_8_strict *file_id,
                                                           struct wire_cst_list_prim_u_8_strict *group_id,
                                                           struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__file__file_done_register_file(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_wire__crate__api__file__file_download_and_decrypt_file_part(int64_t port_,
                                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                                              struct wire_cst_list_prim_u_8_strict *url_prefix,
                                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                              struct wire_cst_list_prim_u_8_strict *part_id,
                                                                              struct wire_cst_list_prim_u_8_strict *content_key,
                                                                              struct wire_cst_list_prim_u_8_strict *verify_key_data);

void frbgen_sentc_wire__crate__api__file__file_download_and_decrypt_file_part_start(int64_t port_,
                                                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                                                    struct wire_cst_list_prim_u_8_strict *url_prefix,
                                                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                                    struct wire_cst_list_prim_u_8_strict *part_id,
                                                                                    struct wire_cst_list_prim_u_8_strict *content_key,
                                                                                    struct wire_cst_list_prim_u_8_strict *verify_key_data);

void frbgen_sentc_wire__crate__api__file__file_download_file_meta(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *base_url,
                                                                  struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                  struct wire_cst_list_prim_u_8_strict *jwt,
                                                                  struct wire_cst_list_prim_u_8_strict *id,
                                                                  struct wire_cst_list_prim_u_8_strict *group_id,
                                                                  struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__file__file_download_part_list(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *base_url,
                                                                  struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                  struct wire_cst_list_prim_u_8_strict *file_id,
                                                                  struct wire_cst_list_prim_u_8_strict *last_sequence);

void frbgen_sentc_wire__crate__api__file__file_file_name_update(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *jwt,
                                                                struct wire_cst_list_prim_u_8_strict *file_id,
                                                                struct wire_cst_list_prim_u_8_strict *content_key,
                                                                struct wire_cst_list_prim_u_8_strict *file_name);

void frbgen_sentc_wire__crate__api__file__file_prepare_register_file(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *master_key_id,
                                                                     struct wire_cst_list_prim_u_8_strict *content_key,
                                                                     struct wire_cst_list_prim_u_8_strict *encrypted_content_key,
                                                                     struct wire_cst_list_prim_u_8_strict *belongs_to_id,
                                                                     struct wire_cst_list_prim_u_8_strict *belongs_to_type,
                                                                     struct wire_cst_list_prim_u_8_strict *file_name);

void frbgen_sentc_wire__crate__api__file__file_register_file(int64_t port_,
                                                             struct wire_cst_list_prim_u_8_strict *base_url,
                                                             struct wire_cst_list_prim_u_8_strict *auth_token,
                                                             struct wire_cst_list_prim_u_8_strict *jwt,
                                                             struct wire_cst_list_prim_u_8_strict *master_key_id,
                                                             struct wire_cst_list_prim_u_8_strict *content_key,
                                                             struct wire_cst_list_prim_u_8_strict *encrypted_content_key,
                                                             struct wire_cst_list_prim_u_8_strict *belongs_to_id,
                                                             struct wire_cst_list_prim_u_8_strict *belongs_to_type,
                                                             struct wire_cst_list_prim_u_8_strict *file_name,
                                                             struct wire_cst_list_prim_u_8_strict *group_id,
                                                             struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__file__file_upload_part(int64_t port_,
                                                           struct wire_cst_list_prim_u_8_strict *base_url,
                                                           struct wire_cst_list_prim_u_8_strict *url_prefix,
                                                           struct wire_cst_list_prim_u_8_strict *auth_token,
                                                           struct wire_cst_list_prim_u_8_strict *jwt,
                                                           struct wire_cst_list_prim_u_8_strict *session_id,
                                                           bool end,
                                                           int32_t sequence,
                                                           struct wire_cst_list_prim_u_8_strict *content_key,
                                                           struct wire_cst_list_prim_u_8_strict *sign_key,
                                                           struct wire_cst_list_prim_u_8_loose *part);

void frbgen_sentc_wire__crate__api__file__file_upload_part_start(int64_t port_,
                                                                 struct wire_cst_list_prim_u_8_strict *base_url,
                                                                 struct wire_cst_list_prim_u_8_strict *url_prefix,
                                                                 struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                 struct wire_cst_list_prim_u_8_strict *jwt,
                                                                 struct wire_cst_list_prim_u_8_strict *session_id,
                                                                 bool end,
                                                                 int32_t sequence,
                                                                 struct wire_cst_list_prim_u_8_strict *content_key,
                                                                 struct wire_cst_list_prim_u_8_strict *sign_key,
                                                                 struct wire_cst_list_prim_u_8_loose *part);

void frbgen_sentc_wire__crate__api__crypto__generate_non_register_sym_key(int64_t port_,
                                                                          struct wire_cst_list_prim_u_8_strict *master_key);

void frbgen_sentc_wire__crate__api__crypto__generate_non_register_sym_key_by_public_key(int64_t port_,
                                                                                        struct wire_cst_list_prim_u_8_strict *reply_public_key);

void frbgen_sentc_wire__crate__api__user__generate_user_register_data(int64_t port_);

void frbgen_sentc_wire__crate__api__user__get_fresh_jwt(int64_t port_,
                                                        struct wire_cst_list_prim_u_8_strict *base_url,
                                                        struct wire_cst_list_prim_u_8_strict *auth_token,
                                                        struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                        struct wire_cst_list_prim_u_8_strict *password,
                                                        struct wire_cst_list_prim_u_8_strict *mfa_token,
                                                        bool *mfa_recovery);

void frbgen_sentc_wire__crate__api__user__get_otp_recover_keys(int64_t port_,
                                                               struct wire_cst_list_prim_u_8_strict *base_url,
                                                               struct wire_cst_list_prim_u_8_strict *auth_token,
                                                               struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_wire__crate__api__user__get_user_devices(int64_t port_,
                                                           struct wire_cst_list_prim_u_8_strict *base_url,
                                                           struct wire_cst_list_prim_u_8_strict *auth_token,
                                                           struct wire_cst_list_prim_u_8_strict *jwt,
                                                           struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                           struct wire_cst_list_prim_u_8_strict *last_fetched_id);

void frbgen_sentc_wire__crate__api__group__group_accept_invite(int64_t port_,
                                                               struct wire_cst_list_prim_u_8_strict *base_url,
                                                               struct wire_cst_list_prim_u_8_strict *auth_token,
                                                               struct wire_cst_list_prim_u_8_strict *jwt,
                                                               struct wire_cst_list_prim_u_8_strict *id,
                                                               struct wire_cst_list_prim_u_8_strict *group_id,
                                                               struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_accept_join_req(int64_t port_,
                                                                 struct wire_cst_list_prim_u_8_strict *base_url,
                                                                 struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                 struct wire_cst_list_prim_u_8_strict *jwt,
                                                                 struct wire_cst_list_prim_u_8_strict *id,
                                                                 struct wire_cst_list_prim_u_8_strict *user_id,
                                                                 int32_t key_count,
                                                                 int32_t *rank,
                                                                 int32_t admin_rank,
                                                                 struct wire_cst_list_prim_u_8_strict *user_public_key,
                                                                 struct wire_cst_list_prim_u_8_strict *group_keys,
                                                                 struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_create_child_group(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                    struct wire_cst_list_prim_u_8_strict *jwt,
                                                                    struct wire_cst_list_prim_u_8_strict *parent_public_key,
                                                                    struct wire_cst_list_prim_u_8_strict *parent_id,
                                                                    int32_t admin_rank,
                                                                    struct wire_cst_list_prim_u_8_strict *group_as_member,
                                                                    struct wire_cst_list_prim_u_8_strict *sign_key,
                                                                    struct wire_cst_list_prim_u_8_strict *starter);

void frbgen_sentc_wire__crate__api__group__group_create_connected_group(int64_t port_,
                                                                        struct wire_cst_list_prim_u_8_strict *base_url,
                                                                        struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                        struct wire_cst_list_prim_u_8_strict *jwt,
                                                                        struct wire_cst_list_prim_u_8_strict *connected_group_id,
                                                                        int32_t admin_rank,
                                                                        struct wire_cst_list_prim_u_8_strict *parent_public_key,
                                                                        struct wire_cst_list_prim_u_8_strict *group_as_member,
                                                                        struct wire_cst_list_prim_u_8_strict *sign_key,
                                                                        struct wire_cst_list_prim_u_8_strict *starter);

void frbgen_sentc_wire__crate__api__group__group_create_group(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                              struct wire_cst_list_prim_u_8_strict *jwt,
                                                              struct wire_cst_list_prim_u_8_strict *creators_public_key,
                                                              struct wire_cst_list_prim_u_8_strict *group_as_member,
                                                              struct wire_cst_list_prim_u_8_strict *sign_key,
                                                              struct wire_cst_list_prim_u_8_strict *starter);

void frbgen_sentc_wire__crate__api__group__group_decrypt_hmac_key(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *group_key,
                                                                  struct wire_cst_list_prim_u_8_strict *server_key_data);

void frbgen_sentc_wire__crate__api__group__group_decrypt_key(int64_t port_,
                                                             struct wire_cst_list_prim_u_8_strict *private_key,
                                                             struct wire_cst_list_prim_u_8_strict *server_key_data,
                                                             struct wire_cst_list_prim_u_8_strict *verify_key);

void frbgen_sentc_wire__crate__api__group__group_decrypt_sortable_key(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *group_key,
                                                                      struct wire_cst_list_prim_u_8_strict *server_key_data);

void frbgen_sentc_wire__crate__api__group__group_delete_group(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                              struct wire_cst_list_prim_u_8_strict *jwt,
                                                              struct wire_cst_list_prim_u_8_strict *id,
                                                              int32_t admin_rank,
                                                              struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_delete_sent_join_req(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                      struct wire_cst_list_prim_u_8_strict *jwt,
                                                                      struct wire_cst_list_prim_u_8_strict *id,
                                                                      int32_t admin_rank,
                                                                      struct wire_cst_list_prim_u_8_strict *join_req_group_id,
                                                                      struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_delete_sent_join_req_user(int64_t port_,
                                                                           struct wire_cst_list_prim_u_8_strict *base_url,
                                                                           struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                           struct wire_cst_list_prim_u_8_strict *jwt,
                                                                           struct wire_cst_list_prim_u_8_strict *join_req_group_id,
                                                                           struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_done_key_rotation(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *private_key,
                                                                   struct wire_cst_list_prim_u_8_strict *public_key,
                                                                   struct wire_cst_list_prim_u_8_strict *pre_group_key,
                                                                   struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_wire__crate__api__group__group_extract_group_data(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_wire__crate__api__group__group_extract_group_keys(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_wire__crate__api__group__group_finish_key_rotation(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *jwt,
                                                                     struct wire_cst_list_prim_u_8_strict *id,
                                                                     struct wire_cst_list_prim_u_8_strict *server_output,
                                                                     struct wire_cst_list_prim_u_8_strict *pre_group_key,
                                                                     struct wire_cst_list_prim_u_8_strict *public_key,
                                                                     struct wire_cst_list_prim_u_8_strict *private_key,
                                                                     struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_all_first_level_children(int64_t port_,
                                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                              struct wire_cst_list_prim_u_8_strict *jwt,
                                                                              struct wire_cst_list_prim_u_8_strict *id,
                                                                              struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                              struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                              struct wire_cst_list_prim_u_8_strict *group_as_member);

WireSyncRust2DartDco frbgen_sentc_wire__crate__api__group__group_get_done_key_rotation_server_input(struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_wire__crate__api__group__group_get_group_data(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *jwt,
                                                                struct wire_cst_list_prim_u_8_strict *id,
                                                                struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_group_key(int64_t port_,
                                                               struct wire_cst_list_prim_u_8_strict *base_url,
                                                               struct wire_cst_list_prim_u_8_strict *auth_token,
                                                               struct wire_cst_list_prim_u_8_strict *jwt,
                                                               struct wire_cst_list_prim_u_8_strict *id,
                                                               struct wire_cst_list_prim_u_8_strict *key_id,
                                                               struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_group_keys(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *jwt,
                                                                struct wire_cst_list_prim_u_8_strict *id,
                                                                struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                struct wire_cst_list_prim_u_8_strict *last_fetched_key_id,
                                                                struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_group_updates(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *base_url,
                                                                   struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                   struct wire_cst_list_prim_u_8_strict *jwt,
                                                                   struct wire_cst_list_prim_u_8_strict *id,
                                                                   struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_groups_for_user(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *jwt,
                                                                     struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                     struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                     struct wire_cst_list_prim_u_8_strict *group_id);

void frbgen_sentc_wire__crate__api__group__group_get_invites_for_user(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                      struct wire_cst_list_prim_u_8_strict *jwt,
                                                                      struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                      struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                      struct wire_cst_list_prim_u_8_strict *group_id,
                                                                      struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_join_reqs(int64_t port_,
                                                               struct wire_cst_list_prim_u_8_strict *base_url,
                                                               struct wire_cst_list_prim_u_8_strict *auth_token,
                                                               struct wire_cst_list_prim_u_8_strict *jwt,
                                                               struct wire_cst_list_prim_u_8_strict *id,
                                                               int32_t admin_rank,
                                                               struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                               struct wire_cst_list_prim_u_8_strict *last_fetched_id,
                                                               struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_member(int64_t port_,
                                                            struct wire_cst_list_prim_u_8_strict *base_url,
                                                            struct wire_cst_list_prim_u_8_strict *auth_token,
                                                            struct wire_cst_list_prim_u_8_strict *jwt,
                                                            struct wire_cst_list_prim_u_8_strict *id,
                                                            struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                            struct wire_cst_list_prim_u_8_strict *last_fetched_id,
                                                            struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_public_key_data(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *id);

void frbgen_sentc_wire__crate__api__group__group_get_sent_join_req(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *base_url,
                                                                   struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                   struct wire_cst_list_prim_u_8_strict *jwt,
                                                                   struct wire_cst_list_prim_u_8_strict *id,
                                                                   int32_t admin_rank,
                                                                   struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                   struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                   struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_get_sent_join_req_user(int64_t port_,
                                                                        struct wire_cst_list_prim_u_8_strict *base_url,
                                                                        struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                        struct wire_cst_list_prim_u_8_strict *jwt,
                                                                        struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                        struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                        struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_invite_user(int64_t port_,
                                                             struct wire_cst_list_prim_u_8_strict *base_url,
                                                             struct wire_cst_list_prim_u_8_strict *auth_token,
                                                             struct wire_cst_list_prim_u_8_strict *jwt,
                                                             struct wire_cst_list_prim_u_8_strict *id,
                                                             struct wire_cst_list_prim_u_8_strict *user_id,
                                                             int32_t key_count,
                                                             int32_t *rank,
                                                             int32_t admin_rank,
                                                             bool auto_invite,
                                                             bool group_invite,
                                                             bool re_invite,
                                                             struct wire_cst_list_prim_u_8_strict *user_public_key,
                                                             struct wire_cst_list_prim_u_8_strict *group_keys,
                                                             struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_invite_user_session(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *jwt,
                                                                     struct wire_cst_list_prim_u_8_strict *id,
                                                                     bool auto_invite,
                                                                     struct wire_cst_list_prim_u_8_strict *session_id,
                                                                     struct wire_cst_list_prim_u_8_strict *user_public_key,
                                                                     struct wire_cst_list_prim_u_8_strict *group_keys,
                                                                     struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_join_req(int64_t port_,
                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                          struct wire_cst_list_prim_u_8_strict *jwt,
                                                          struct wire_cst_list_prim_u_8_strict *id,
                                                          struct wire_cst_list_prim_u_8_strict *group_id,
                                                          struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_join_user_session(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *base_url,
                                                                   struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                   struct wire_cst_list_prim_u_8_strict *jwt,
                                                                   struct wire_cst_list_prim_u_8_strict *id,
                                                                   struct wire_cst_list_prim_u_8_strict *session_id,
                                                                   struct wire_cst_list_prim_u_8_strict *user_public_key,
                                                                   struct wire_cst_list_prim_u_8_strict *group_keys,
                                                                   struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_key_rotation(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                              struct wire_cst_list_prim_u_8_strict *jwt,
                                                              struct wire_cst_list_prim_u_8_strict *id,
                                                              struct wire_cst_list_prim_u_8_strict *public_key,
                                                              struct wire_cst_list_prim_u_8_strict *pre_group_key,
                                                              struct wire_cst_list_prim_u_8_strict *sign_key,
                                                              struct wire_cst_list_prim_u_8_strict *starter,
                                                              struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_kick_user(int64_t port_,
                                                           struct wire_cst_list_prim_u_8_strict *base_url,
                                                           struct wire_cst_list_prim_u_8_strict *auth_token,
                                                           struct wire_cst_list_prim_u_8_strict *jwt,
                                                           struct wire_cst_list_prim_u_8_strict *id,
                                                           struct wire_cst_list_prim_u_8_strict *user_id,
                                                           int32_t admin_rank,
                                                           struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_pre_done_key_rotation(int64_t port_,
                                                                       struct wire_cst_list_prim_u_8_strict *base_url,
                                                                       struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                       struct wire_cst_list_prim_u_8_strict *jwt,
                                                                       struct wire_cst_list_prim_u_8_strict *id,
                                                                       struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_prepare_create_group(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *creators_public_key,
                                                                      struct wire_cst_list_prim_u_8_strict *sign_key,
                                                                      struct wire_cst_list_prim_u_8_strict *starter);

void frbgen_sentc_wire__crate__api__group__group_prepare_key_rotation(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *pre_group_key,
                                                                      struct wire_cst_list_prim_u_8_strict *public_key,
                                                                      struct wire_cst_list_prim_u_8_strict *sign_key,
                                                                      struct wire_cst_list_prim_u_8_strict *starter);

void frbgen_sentc_wire__crate__api__group__group_prepare_keys_for_new_member(int64_t port_,
                                                                             struct wire_cst_list_prim_u_8_strict *user_public_key,
                                                                             struct wire_cst_list_prim_u_8_strict *group_keys,
                                                                             int32_t key_count,
                                                                             int32_t *rank,
                                                                             int32_t admin_rank);

WireSyncRust2DartDco frbgen_sentc_wire__crate__api__group__group_prepare_update_rank(struct wire_cst_list_prim_u_8_strict *user_id,
                                                                                     int32_t rank,
                                                                                     int32_t admin_rank);

void frbgen_sentc_wire__crate__api__group__group_reject_invite(int64_t port_,
                                                               struct wire_cst_list_prim_u_8_strict *base_url,
                                                               struct wire_cst_list_prim_u_8_strict *auth_token,
                                                               struct wire_cst_list_prim_u_8_strict *jwt,
                                                               struct wire_cst_list_prim_u_8_strict *id,
                                                               struct wire_cst_list_prim_u_8_strict *group_id,
                                                               struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_reject_join_req(int64_t port_,
                                                                 struct wire_cst_list_prim_u_8_strict *base_url,
                                                                 struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                 struct wire_cst_list_prim_u_8_strict *jwt,
                                                                 struct wire_cst_list_prim_u_8_strict *id,
                                                                 int32_t admin_rank,
                                                                 struct wire_cst_list_prim_u_8_strict *rejected_user_id,
                                                                 struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_stop_group_invites(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                    struct wire_cst_list_prim_u_8_strict *jwt,
                                                                    struct wire_cst_list_prim_u_8_strict *id,
                                                                    int32_t admin_rank,
                                                                    struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__group__group_update_rank(int64_t port_,
                                                             struct wire_cst_list_prim_u_8_strict *base_url,
                                                             struct wire_cst_list_prim_u_8_strict *auth_token,
                                                             struct wire_cst_list_prim_u_8_strict *jwt,
                                                             struct wire_cst_list_prim_u_8_strict *id,
                                                             struct wire_cst_list_prim_u_8_strict *user_id,
                                                             int32_t rank,
                                                             int32_t admin_rank,
                                                             struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__user__init_user(int64_t port_,
                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                    struct wire_cst_list_prim_u_8_strict *jwt,
                                                    struct wire_cst_list_prim_u_8_strict *refresh_token);

void frbgen_sentc_wire__crate__api__group__leave_group(int64_t port_,
                                                       struct wire_cst_list_prim_u_8_strict *base_url,
                                                       struct wire_cst_list_prim_u_8_strict *auth_token,
                                                       struct wire_cst_list_prim_u_8_strict *jwt,
                                                       struct wire_cst_list_prim_u_8_strict *id,
                                                       struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_wire__crate__api__user__login(int64_t port_,
                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_wire__crate__api__user__mfa_login(int64_t port_,
                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                    struct wire_cst_list_prim_u_8_strict *master_key_encryption,
                                                    struct wire_cst_list_prim_u_8_strict *auth_key,
                                                    struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                    struct wire_cst_list_prim_u_8_strict *token,
                                                    bool recovery);

WireSyncRust2DartDco frbgen_sentc_wire__crate__api__user__prepare_check_user_identifier_available(struct wire_cst_list_prim_u_8_strict *user_identifier);

void frbgen_sentc_wire__crate__api__user__prepare_register(int64_t port_,
                                                           struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                           struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_wire__crate__api__user__prepare_register_device(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *server_output,
                                                                  struct wire_cst_list_prim_u_8_strict *user_keys,
                                                                  int32_t key_count);

void frbgen_sentc_wire__crate__api__user__prepare_register_device_start(int64_t port_,
                                                                        struct wire_cst_list_prim_u_8_strict *device_identifier,
                                                                        struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_wire__crate__api__user__refresh_jwt(int64_t port_,
                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                      struct wire_cst_list_prim_u_8_strict *jwt,
                                                      struct wire_cst_list_prim_u_8_strict *refresh_token);

void frbgen_sentc_wire__crate__api__user__register(int64_t port_,
                                                   struct wire_cst_list_prim_u_8_strict *base_url,
                                                   struct wire_cst_list_prim_u_8_strict *auth_token,
                                                   struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                   struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_wire__crate__api__user__register_device(int64_t port_,
                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                          struct wire_cst_list_prim_u_8_strict *jwt,
                                                          struct wire_cst_list_prim_u_8_strict *server_output,
                                                          int32_t key_count,
                                                          struct wire_cst_list_prim_u_8_strict *user_keys);

void frbgen_sentc_wire__crate__api__user__register_device_start(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *device_identifier,
                                                                struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_wire__crate__api__user__register_otp(int64_t port_,
                                                       struct wire_cst_list_prim_u_8_strict *base_url,
                                                       struct wire_cst_list_prim_u_8_strict *auth_token,
                                                       struct wire_cst_list_prim_u_8_strict *jwt,
                                                       struct wire_cst_list_prim_u_8_strict *issuer,
                                                       struct wire_cst_list_prim_u_8_strict *audience);

void frbgen_sentc_wire__crate__api__user__register_raw_otp(int64_t port_,
                                                           struct wire_cst_list_prim_u_8_strict *base_url,
                                                           struct wire_cst_list_prim_u_8_strict *auth_token,
                                                           struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_wire__crate__api__user__reset_otp(int64_t port_,
                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                    struct wire_cst_list_prim_u_8_strict *jwt,
                                                    struct wire_cst_list_prim_u_8_strict *issuer,
                                                    struct wire_cst_list_prim_u_8_strict *audience);

void frbgen_sentc_wire__crate__api__user__reset_password(int64_t port_,
                                                         struct wire_cst_list_prim_u_8_strict *base_url,
                                                         struct wire_cst_list_prim_u_8_strict *auth_token,
                                                         struct wire_cst_list_prim_u_8_strict *jwt,
                                                         struct wire_cst_list_prim_u_8_strict *new_password,
                                                         struct wire_cst_list_prim_u_8_strict *decrypted_private_key,
                                                         struct wire_cst_list_prim_u_8_strict *decrypted_sign_key);

void frbgen_sentc_wire__crate__api__user__reset_raw_otp(int64_t port_,
                                                        struct wire_cst_list_prim_u_8_strict *base_url,
                                                        struct wire_cst_list_prim_u_8_strict *auth_token,
                                                        struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_wire__crate__api__crypto__search(int64_t port_,
                                                   struct wire_cst_list_prim_u_8_strict *key,
                                                   struct wire_cst_list_prim_u_8_strict *data);

void frbgen_sentc_wire__crate__api__crypto__sortable_encrypt_number(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *key,
                                                                    uint64_t data);

void frbgen_sentc_wire__crate__api__crypto__sortable_encrypt_raw_number(int64_t port_,
                                                                        struct wire_cst_list_prim_u_8_strict *key,
                                                                        uint64_t data);

void frbgen_sentc_wire__crate__api__crypto__sortable_encrypt_raw_string(int64_t port_,
                                                                        struct wire_cst_list_prim_u_8_strict *key,
                                                                        struct wire_cst_list_prim_u_8_strict *data);

void frbgen_sentc_wire__crate__api__crypto__sortable_encrypt_string(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *key,
                                                                    struct wire_cst_list_prim_u_8_strict *data);

void frbgen_sentc_wire__crate__api__crypto__split_head_and_encrypted_data(int64_t port_,
                                                                          struct wire_cst_list_prim_u_8_loose *data);

void frbgen_sentc_wire__crate__api__crypto__split_head_and_encrypted_string(int64_t port_,
                                                                            struct wire_cst_list_prim_u_8_strict *data);

void frbgen_sentc_wire__crate__api__user__update_user(int64_t port_,
                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                      struct wire_cst_list_prim_u_8_strict *jwt,
                                                      struct wire_cst_list_prim_u_8_strict *user_identifier);

void frbgen_sentc_wire__crate__api__user__user_create_safety_number(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *verify_key_1,
                                                                    struct wire_cst_list_prim_u_8_strict *user_id_1,
                                                                    struct wire_cst_list_prim_u_8_strict *verify_key_2,
                                                                    struct wire_cst_list_prim_u_8_strict *user_id_2);

void frbgen_sentc_wire__crate__api__user__user_device_key_session_upload(int64_t port_,
                                                                         struct wire_cst_list_prim_u_8_strict *base_url,
                                                                         struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                         struct wire_cst_list_prim_u_8_strict *jwt,
                                                                         struct wire_cst_list_prim_u_8_strict *session_id,
                                                                         struct wire_cst_list_prim_u_8_strict *user_public_key,
                                                                         struct wire_cst_list_prim_u_8_strict *group_keys);

void frbgen_sentc_wire__crate__api__user__user_fetch_public_key(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *user_id);

void frbgen_sentc_wire__crate__api__user__user_fetch_verify_key(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *user_id,
                                                                struct wire_cst_list_prim_u_8_strict *verify_key_id);

void frbgen_sentc_wire__crate__api__user__user_finish_key_rotation(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *base_url,
                                                                   struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                   struct wire_cst_list_prim_u_8_strict *jwt,
                                                                   struct wire_cst_list_prim_u_8_strict *server_output,
                                                                   struct wire_cst_list_prim_u_8_strict *pre_group_key,
                                                                   struct wire_cst_list_prim_u_8_strict *public_key,
                                                                   struct wire_cst_list_prim_u_8_strict *private_key);

void frbgen_sentc_wire__crate__api__user__user_get_done_key_rotation_server_input(int64_t port_,
                                                                                  struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_wire__crate__api__user__user_key_rotation(int64_t port_,
                                                            struct wire_cst_list_prim_u_8_strict *base_url,
                                                            struct wire_cst_list_prim_u_8_strict *auth_token,
                                                            struct wire_cst_list_prim_u_8_strict *jwt,
                                                            struct wire_cst_list_prim_u_8_strict *public_device_key,
                                                            struct wire_cst_list_prim_u_8_strict *pre_user_key);

void frbgen_sentc_wire__crate__api__user__user_pre_done_key_rotation(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_wire__crate__api__user__user_verify_user_public_key(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *verify_key,
                                                                      struct wire_cst_list_prim_u_8_strict *public_key);

bool *frbgen_sentc_cst_new_box_autoadd_bool(bool value);

int32_t *frbgen_sentc_cst_new_box_autoadd_i_32(int32_t value);

uint32_t *frbgen_sentc_cst_new_box_autoadd_u_32(uint32_t value);

struct wire_cst_list_String *frbgen_sentc_cst_new_list_String(int32_t len);

struct wire_cst_list_file_part_list_item *frbgen_sentc_cst_new_list_file_part_list_item(int32_t len);

struct wire_cst_list_group_children_list *frbgen_sentc_cst_new_list_group_children_list(int32_t len);

struct wire_cst_list_group_invite_req_list *frbgen_sentc_cst_new_list_group_invite_req_list(int32_t len);

struct wire_cst_list_group_join_req_list *frbgen_sentc_cst_new_list_group_join_req_list(int32_t len);

struct wire_cst_list_group_out_data_hmac_keys *frbgen_sentc_cst_new_list_group_out_data_hmac_keys(int32_t len);

struct wire_cst_list_group_out_data_keys *frbgen_sentc_cst_new_list_group_out_data_keys(int32_t len);

struct wire_cst_list_group_out_data_sortable_keys *frbgen_sentc_cst_new_list_group_out_data_sortable_keys(int32_t len);

struct wire_cst_list_group_user_list_item *frbgen_sentc_cst_new_list_group_user_list_item(int32_t len);

struct wire_cst_list_key_rotation_get_out *frbgen_sentc_cst_new_list_key_rotation_get_out(int32_t len);

struct wire_cst_list_list_groups *frbgen_sentc_cst_new_list_list_groups(int32_t len);

struct wire_cst_list_prim_u_8_loose *frbgen_sentc_cst_new_list_prim_u_8_loose(int32_t len);

struct wire_cst_list_prim_u_8_strict *frbgen_sentc_cst_new_list_prim_u_8_strict(int32_t len);

struct wire_cst_list_user_device_list *frbgen_sentc_cst_new_list_user_device_list(int32_t len);

struct wire_cst_list_user_key_data *frbgen_sentc_cst_new_list_user_key_data(int32_t len);
static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_box_autoadd_bool);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_box_autoadd_i_32);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_box_autoadd_u_32);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_String);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_file_part_list_item);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_group_children_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_group_invite_req_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_group_join_req_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_group_out_data_hmac_keys);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_group_out_data_keys);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_group_out_data_sortable_keys);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_group_user_list_item);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_key_rotation_get_out);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_list_groups);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_prim_u_8_loose);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_prim_u_8_strict);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_user_device_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_cst_new_list_user_key_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__create_searchable);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__create_searchable_raw);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__decrypt_asymmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__decrypt_raw_asymmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__decrypt_raw_symmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__decrypt_string_asymmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__decrypt_string_symmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__decrypt_sym_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__decrypt_sym_key_by_private_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__decrypt_symmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__deserialize_head_from_string);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__done_fetch_sym_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__done_fetch_sym_key_by_private_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__encrypt_asymmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__encrypt_raw_asymmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__encrypt_raw_symmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__encrypt_string_asymmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__encrypt_string_symmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__encrypt_symmetric);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__generate_non_register_sym_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__generate_non_register_sym_key_by_public_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__search);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__sortable_encrypt_number);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__sortable_encrypt_raw_number);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__sortable_encrypt_raw_string);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__sortable_encrypt_string);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__split_head_and_encrypted_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__crypto__split_head_and_encrypted_string);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_delete_file);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_done_register_file);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_download_and_decrypt_file_part);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_download_and_decrypt_file_part_start);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_download_file_meta);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_download_part_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_file_name_update);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_prepare_register_file);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_register_file);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_upload_part);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__file__file_upload_part_start);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_accept_invite);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_accept_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_create_child_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_create_connected_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_create_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_decrypt_hmac_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_decrypt_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_decrypt_sortable_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_delete_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_delete_sent_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_delete_sent_join_req_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_done_key_rotation);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_extract_group_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_extract_group_keys);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_finish_key_rotation);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_all_first_level_children);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_done_key_rotation_server_input);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_group_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_group_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_group_keys);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_group_updates);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_groups_for_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_invites_for_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_join_reqs);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_member);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_public_key_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_sent_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_get_sent_join_req_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_invite_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_invite_user_session);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_join_user_session);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_key_rotation);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_kick_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_pre_done_key_rotation);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_prepare_create_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_prepare_key_rotation);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_prepare_keys_for_new_member);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_prepare_update_rank);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_reject_invite);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_reject_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_stop_group_invites);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__group_update_rank);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__group__leave_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__change_password);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__check_user_identifier_available);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__decode_jwt);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__delete_device);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__delete_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__disable_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__done_check_user_identifier_available);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__done_fetch_user_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__done_register);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__done_register_device_start);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__extract_user_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__fetch_user_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__generate_user_register_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__get_fresh_jwt);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__get_otp_recover_keys);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__get_user_devices);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__init_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__login);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__mfa_login);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__prepare_check_user_identifier_available);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__prepare_register);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__prepare_register_device);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__prepare_register_device_start);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__refresh_jwt);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__register);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__register_device);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__register_device_start);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__register_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__register_raw_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__reset_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__reset_password);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__reset_raw_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__update_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_create_safety_number);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_device_key_session_upload);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_fetch_public_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_fetch_verify_key);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_finish_key_rotation);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_get_done_key_rotation_server_input);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_key_rotation);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_pre_done_key_rotation);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_wire__crate__api__user__user_verify_user_public_key);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}

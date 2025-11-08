using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Axle.Migrations
{
    /// <inheritdoc />
    public partial class RemoveNetPrefix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_NetRoleClaims_NetRoles_RoleId",
                table: "NetRoleClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserClaims_NetUsers_UserId",
                table: "NetUserClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserLogins_NetUsers_UserId",
                table: "NetUserLogins");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserRoles_NetRoles_RoleId",
                table: "NetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserRoles_NetUsers_UserId",
                table: "NetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_NetUserTokens_NetUsers_UserId",
                table: "NetUserTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_Nodes_NetUsers_CreatedById",
                table: "Nodes");

            migrationBuilder.DropForeignKey(
                name: "FK_Nodes_NetUsers_ModifiedById",
                table: "Nodes");

            migrationBuilder.DropForeignKey(
                name: "FK_RefreshTokens_NetUsers_UserId",
                table: "RefreshTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_TenantUsers_NetUsers_UserId",
                table: "TenantUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUserTokens",
                table: "NetUserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUsers",
                table: "NetUsers");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUserRoles",
                table: "NetUserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUserLogins",
                table: "NetUserLogins");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetUserClaims",
                table: "NetUserClaims");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetRoles",
                table: "NetRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_NetRoleClaims",
                table: "NetRoleClaims");

            migrationBuilder.RenameTable(
                name: "NetUserTokens",
                newName: "UserTokens");

            migrationBuilder.RenameTable(
                name: "NetUsers",
                newName: "Users");

            migrationBuilder.RenameTable(
                name: "NetUserRoles",
                newName: "UserRoles");

            migrationBuilder.RenameTable(
                name: "NetUserLogins",
                newName: "UserLogins");

            migrationBuilder.RenameTable(
                name: "NetUserClaims",
                newName: "UserClaims");

            migrationBuilder.RenameTable(
                name: "NetRoles",
                newName: "Roles");

            migrationBuilder.RenameTable(
                name: "NetRoleClaims",
                newName: "RoleClaims");

            migrationBuilder.RenameIndex(
                name: "IX_NetUserRoles_RoleId",
                table: "UserRoles",
                newName: "IX_UserRoles_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_NetUserLogins_UserId",
                table: "UserLogins",
                newName: "IX_UserLogins_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_NetUserClaims_UserId",
                table: "UserClaims",
                newName: "IX_UserClaims_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_NetRoleClaims_RoleId",
                table: "RoleClaims",
                newName: "IX_RoleClaims_RoleId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserTokens",
                table: "UserTokens",
                columns: new[] { "UserId", "LoginProvider", "Name" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_Users",
                table: "Users",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserRoles",
                table: "UserRoles",
                columns: new[] { "UserId", "RoleId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserLogins",
                table: "UserLogins",
                columns: new[] { "LoginProvider", "ProviderKey" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserClaims",
                table: "UserClaims",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Roles",
                table: "Roles",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_RoleClaims",
                table: "RoleClaims",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Nodes_Users_CreatedById",
                table: "Nodes",
                column: "CreatedById",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Nodes_Users_ModifiedById",
                table: "Nodes",
                column: "ModifiedById",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshTokens_Users_UserId",
                table: "RefreshTokens",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RoleClaims_Roles_RoleId",
                table: "RoleClaims",
                column: "RoleId",
                principalTable: "Roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TenantUsers_Users_UserId",
                table: "TenantUsers",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserClaims_Users_UserId",
                table: "UserClaims",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserLogins_Users_UserId",
                table: "UserLogins",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserRoles_Roles_RoleId",
                table: "UserRoles",
                column: "RoleId",
                principalTable: "Roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserRoles_Users_UserId",
                table: "UserRoles",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTokens_Users_UserId",
                table: "UserTokens",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Nodes_Users_CreatedById",
                table: "Nodes");

            migrationBuilder.DropForeignKey(
                name: "FK_Nodes_Users_ModifiedById",
                table: "Nodes");

            migrationBuilder.DropForeignKey(
                name: "FK_RefreshTokens_Users_UserId",
                table: "RefreshTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_RoleClaims_Roles_RoleId",
                table: "RoleClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_TenantUsers_Users_UserId",
                table: "TenantUsers");

            migrationBuilder.DropForeignKey(
                name: "FK_UserClaims_Users_UserId",
                table: "UserClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_UserLogins_Users_UserId",
                table: "UserLogins");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Roles_RoleId",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_UserRoles_Users_UserId",
                table: "UserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTokens_Users_UserId",
                table: "UserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserTokens",
                table: "UserTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Users",
                table: "Users");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserRoles",
                table: "UserRoles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserLogins",
                table: "UserLogins");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserClaims",
                table: "UserClaims");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Roles",
                table: "Roles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_RoleClaims",
                table: "RoleClaims");

            migrationBuilder.RenameTable(
                name: "UserTokens",
                newName: "NetUserTokens");

            migrationBuilder.RenameTable(
                name: "Users",
                newName: "NetUsers");

            migrationBuilder.RenameTable(
                name: "UserRoles",
                newName: "NetUserRoles");

            migrationBuilder.RenameTable(
                name: "UserLogins",
                newName: "NetUserLogins");

            migrationBuilder.RenameTable(
                name: "UserClaims",
                newName: "NetUserClaims");

            migrationBuilder.RenameTable(
                name: "Roles",
                newName: "NetRoles");

            migrationBuilder.RenameTable(
                name: "RoleClaims",
                newName: "NetRoleClaims");

            migrationBuilder.RenameIndex(
                name: "IX_UserRoles_RoleId",
                table: "NetUserRoles",
                newName: "IX_NetUserRoles_RoleId");

            migrationBuilder.RenameIndex(
                name: "IX_UserLogins_UserId",
                table: "NetUserLogins",
                newName: "IX_NetUserLogins_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_UserClaims_UserId",
                table: "NetUserClaims",
                newName: "IX_NetUserClaims_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_RoleClaims_RoleId",
                table: "NetRoleClaims",
                newName: "IX_NetRoleClaims_RoleId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUserTokens",
                table: "NetUserTokens",
                columns: new[] { "UserId", "LoginProvider", "Name" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUsers",
                table: "NetUsers",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUserRoles",
                table: "NetUserRoles",
                columns: new[] { "UserId", "RoleId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUserLogins",
                table: "NetUserLogins",
                columns: new[] { "LoginProvider", "ProviderKey" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetUserClaims",
                table: "NetUserClaims",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetRoles",
                table: "NetRoles",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_NetRoleClaims",
                table: "NetRoleClaims",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_NetRoleClaims_NetRoles_RoleId",
                table: "NetRoleClaims",
                column: "RoleId",
                principalTable: "NetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserClaims_NetUsers_UserId",
                table: "NetUserClaims",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserLogins_NetUsers_UserId",
                table: "NetUserLogins",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserRoles_NetRoles_RoleId",
                table: "NetUserRoles",
                column: "RoleId",
                principalTable: "NetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserRoles_NetUsers_UserId",
                table: "NetUserRoles",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_NetUserTokens_NetUsers_UserId",
                table: "NetUserTokens",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Nodes_NetUsers_CreatedById",
                table: "Nodes",
                column: "CreatedById",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Nodes_NetUsers_ModifiedById",
                table: "Nodes",
                column: "ModifiedById",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshTokens_NetUsers_UserId",
                table: "RefreshTokens",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TenantUsers_NetUsers_UserId",
                table: "TenantUsers",
                column: "UserId",
                principalTable: "NetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
